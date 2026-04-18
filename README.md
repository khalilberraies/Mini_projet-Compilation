# BotScript IDE (User Manual)

BotScript IDE is a web-based IDE for **BotScript**, a small domain-specific language (DSL) designed to control a virtual drawing robot. The project demonstrates classic compiler concepts (lexing, parsing, AST construction) using **Flex/Bison compiled to WebAssembly**, and provides compiler visualizations (tokens + AST) directly in the UI.

## 1) Quick start (Windows / Linux)

### Prerequisites
- Node.js **18+**
- npm (comes with Node)

### Run the IDE
```bash
npm install
npm run dev
```
Then open `http://localhost:3000`.

> Note: The repository already includes a prebuilt WebAssembly compiler in `public/wasm/`, so you can run the IDE without installing Flex/Bison.

## 2) How to use the IDE

1. Open the **Editor** tab and write BotScript.
2. Click **Run**.
3. Check the **Compiler** tab to inspect:
   - the token stream (what the lexer produced)
   - the AST in JSON (what the parser built)
4. The **Canvas** shows the robot path (execution trace).

## 3) The BotScript DSL (detailed reference)

### 3.1 Lexical rules

**Comments** (ignored):
- `// ...` single-line
- `# ...` single-line
- `/* ... */` multi-line

**Literals**:
- Numbers: integers and reals (e.g. `42`, `3.14`, `1e3`, `2.5E-2`)
- Strings: double-quoted strings with escapes (e.g. `"#3b82f6"`, `"hello\nworld"`)

**Identifiers**:
- `[a-zA-Z_][a-zA-Z0-9_]*`

**Keywords**:
- Declarations / control flow: `let`, `repeat`, `if`, `else`, `while`
- Robot commands: `forward`, `turn`, `color`, `penDown`, `penUp`

### 3.2 Program structure

A program is a sequence of statements. Statements end with `;` for declarations/assignments/commands. Blocks use `{ ... }`.

Supported statements:
- Variable declaration: `let name = expression;`
- Assignment: `name = expression;`
- Fixed loop: `repeat expression { statements }`
- While loop: `while (expression) { statements }`
- Conditional:
  - `if (expression) { statements }`
  - `if (expression) { statements } else { statements }`
- Command call:
  - `forward(expr);`, `turn(expr);`, `color(expr);`
  - `penDown();`, `penUp();`

### 3.3 Expressions and operators

BotScript uses **expressions everywhere** (loop counts, conditions, command arguments).

**Arithmetic**: `+`, `-`, `*`, `/`

**Relational**: `<`, `>`, `<=`, `>=`, `==`, `!=`

**Logical**:
- `&&` (and)
- `||` (or)
- `!`  (not)

**Precedence** (high → low):
1. Unary `!`
2. `*` `/`
3. `+` `-`
4. Relational: `<` `>` `<=` `>=` `==` `!=`
5. `&&`
6. `||`

> Implementation note: conditions are evaluated numerically (`0` is false, non-zero is true).

### 3.4 Built-in commands (robot API)

| Command | Signature | Effect |
|---|---|---|
| `forward` | `forward(dist);` | Move forward by `dist` units; draws if pen is down. |
| `turn` | `turn(angle);` | Rotate by `angle` degrees (clockwise). |
| `color` | `color("#RRGGBB");` | Set pen color (string). |
| `penDown` | `penDown();` | Start drawing. |
| `penUp` | `penUp();` | Stop drawing. |

## 4) Examples

### Example A — square
```c
let size = 100;
color("#3b82f6");
penDown();

repeat 4 {
  forward(size);
  turn(90);
}
```

### Example B — spiral
```c
let step = 5;
let i = 0;
color("#10b981");
penDown();

while (i < 60) {
  forward(step);
  turn(20);
  step = step + 2;
  i = i + 1;
}
```

### Example C — condition + logical operators
```c
let x = 0;
penDown();

while (x < 200) {
  if ((x < 80) || (x > 160)) {
    color("#ef4444");
  } else {
    color("#3b82f6");
  }

  forward(5);
  turn(10);
  x = x + 5;
}
```

## 5) Rebuilding the Flex/Bison compiler (WASM)

The WebAssembly compiler is generated from the specs in `src/specs/`:
- `botscript.l` (Flex lexer)
- `botscript.y` (Bison parser + AST actions)

The build script is `scripts/build-wasm.sh` and outputs to `public/wasm/`.

### Option 1 (recommended) — Linux / WSL (easiest for Flex/Bison)
1. Install Flex + Bison (example for Debian/Ubuntu):
   ```bash
   sudo apt update
   sudo apt install -y flex bison
   ```
2. Install and activate Emscripten SDK (emsdk) and ensure `emcc` is in your `PATH`.
3. Build the compiler + start the IDE:
   ```bash
   npm run dev:wasm
   ```

### Option 2 — Windows native (possible, but more tooling)
You need:
- A Bash environment to run `scripts/build-wasm.sh` (Git Bash works; WSL works)
- Flex/Bison for Windows (commonly provided by **WinFlexBison**, exposing `win_flex` and `win_bison`)
- Emscripten SDK (emsdk) with `emcc` available

Then:
```bash
npm run dev:wasm
```

## 6) Project structure (high level)

- `src/App.tsx`: UI (editor, compiler panels, canvas)
- `src/wasm/botscriptWasm.ts`: loads and calls the WASM compiler
- `src/specs/`: Flex/Bison specs + runtime (`wasm_runtime.c`, `wasm_bridge.h`)
- `public/wasm/`: generated `botscript.js` + `botscript.wasm`

## 7) Troubleshooting

- **Port 3000 already used**: change the port in `package.json` (script `dev`) or stop the process using it.
- **`npm run dev:wasm` fails on Windows**: use WSL (Ubuntu) or ensure `win_flex`, `win_bison`, and `emcc` are on `PATH`.
