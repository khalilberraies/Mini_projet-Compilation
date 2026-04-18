import { Lexer, Parser, Interpreter, Token, ASTNode } from "../compiler";
import fs from "node:fs";
import path from "node:path";

// =========================
// Detailed Test Infrastructure
// =========================
type TestFn = () => void;

interface TestResult {
  name: string;
  status: "PASS" | "FAIL";
  input?: string;
  expected?: unknown;
  actual?: unknown;
  notes?: string;
  error?: string;
  startedAt: string;
  endedAt: string;
  durationMs: number;
}

const tests: { name: string; fn: TestFn }[] = [];
const results: TestResult[] = [];

let currentContext: Omit<TestResult, "name" | "status" | "startedAt" | "endedAt" | "durationMs"> = {};

function setTestContext(ctx: Partial<Omit<TestResult, "name" | "status" | "startedAt" | "endedAt" | "durationMs">>) {
  currentContext = { ...currentContext, ...ctx };
}

function clearTestContext() {
  currentContext = {};
}

function test(name: string, fn: TestFn) {
  tests.push({ name, fn });
}

function normalize(v: unknown) {
  return JSON.stringify(v, null, 2);
}

function assertEqual(actual: unknown, expected: unknown, msg?: string) {
  const a = JSON.stringify(actual);
  const e = JSON.stringify(expected);
  if (a !== e) {
    throw new Error(
      msg ||
        `Assertion failed\nExpected:\n${normalize(expected)}\nActual:\n${normalize(actual)}`
    );
  }
}

function assert(condition: boolean, msg: string) {
  if (!condition) throw new Error(msg);
}

// =========================
// Compiler helpers
// =========================
function lexAll(input: string): Token[] {
  const lexer = new Lexer(input);
  const tokens: Token[] = [];
  while (true) {
    const t = lexer.yylex();
    tokens.push(t);
    if (t.type === "FIN") break;
  }
  return tokens;
}

function parse(input: string) {
  const lexer = new Lexer(input);
  const parser = new Parser(lexer);
  return parser.yyparse();
}

function runPipeline(input: string) {
  const lexer = new Lexer(input);
  const parser = new Parser(lexer);
  const { ast, errors } = parser.yyparse();
  const interpreter = new Interpreter(ast);
  const exec = interpreter.execute();
  return { parserErrors: errors, semanticErrors: exec.errors, state: exec.state };
}

function expectProgram(ast: ASTNode): Extract<ASTNode, { type: "Program" }> {
  if (ast.type !== "Program") {
    throw new Error(`Expected Program AST, got ${ast.type}`);
  }
  return ast;
}

// =========================
// Detailed logger
// =========================
function run() {
  let passed = 0;

  for (const t of tests) {
    const start = Date.now();
    const startedAt = new Date(start).toISOString();
    clearTestContext();

    try {
      t.fn();
      const end = Date.now();

      const r: TestResult = {
        name: t.name,
        status: "PASS",
        ...currentContext,
        startedAt,
        endedAt: new Date(end).toISOString(),
        durationMs: end - start,
      };
      results.push(r);

      console.log(`✅ ${t.name}`);
      if (r.expected !== undefined) console.log(`   expected: ${normalize(r.expected)}`);
      if (r.actual !== undefined) console.log(`   actual:   ${normalize(r.actual)}`);
      if (r.notes) console.log(`   notes:    ${r.notes}`);

      passed++;
    } catch (err: unknown) {
      const end = Date.now();
      const msg = err instanceof Error ? err.message : String(err);

      const r: TestResult = {
        name: t.name,
        status: "FAIL",
        ...currentContext,
        error: msg,
        startedAt,
        endedAt: new Date(end).toISOString(),
        durationMs: end - start,
      };
      results.push(r);

      console.error(`❌ ${t.name}`);
      if (r.expected !== undefined) console.error(`   expected: ${normalize(r.expected)}`);
      if (r.actual !== undefined) console.error(`   actual:   ${normalize(r.actual)}`);
      if (r.notes) console.error(`   notes:    ${r.notes}`);
      console.error(`   error:    ${msg}`);
    }
  }

  console.log(`\n${passed}/${tests.length} tests passed`);

  writeDetailedReport({
    total: tests.length,
    passed,
    failed: tests.length - passed,
    results,
  });
}

function writeDetailedReport(payload: {
  total: number;
  passed: number;
  failed: number;
  results: TestResult[];
}) {
  const outPath = path.join(process.cwd(), "src", "tests", "interpreter_tests_output.txt");
  const now = new Date().toISOString();

  let report = "";
  report += "============================================================\n";
  report += "INTERPRETER TESTS - DETAILED OUTPUT REPORT\n";
  report += "============================================================\n";
  report += `Generated at: ${now}\n`;
  report += `Total: ${payload.total}\n`;
  report += `Passed: ${payload.passed}\n`;
  report += `Failed: ${payload.failed}\n`;
  report += "============================================================\n\n";

  payload.results.forEach((r, i) => {
    report += `#${i + 1} ${r.name}\n`;
    report += `Status      : ${r.status}\n`;
    report += `Started     : ${r.startedAt}\n`;
    report += `Ended       : ${r.endedAt}\n`;
    report += `Duration(ms): ${r.durationMs}\n`;
    if (r.input !== undefined) report += `Input:\n${r.input}\n`;
    if (r.expected !== undefined) report += `Expected:\n${normalize(r.expected)}\n`;
    if (r.actual !== undefined) report += `Actual:\n${normalize(r.actual)}\n`;
    if (r.notes) report += `Notes:\n${r.notes}\n`;
    if (r.error) report += `Error:\n${r.error}\n`;
    report += "------------------------------------------------------------\n\n";
  });

  fs.writeFileSync(outPath, report, "utf-8");
  console.log(`\n📝 Detailed report written to: ${outPath}`);
}

// =========================
// TOKENIZATION TESTS
// =========================
test("tokenize - all tokens in one string", () => {
  const input = `let x = 12; x = 3.5 + 2 * 7 - 1 / 2;
if (x >= 10) { forward(5); } else { turn(90); }
color("red"); penDown(); penUp(); #comment`;

  const tokens = lexAll(input).map((t) => ({ type: t.type, value: t.value }));
  const types = tokens.map((t) => t.type);

  const expected = {
    has: ["MOTCLE", "IDENT", "ENTIER", "REEL", "OP_ARTHM", "OP_REL", "AFFECT", "PUNCT", "CHAINE"],
  };

  const actual = {
    has: expected.has.filter((x) => types.includes(x as any)),
    tokenCount: tokens.length,
  };

  setTestContext({
    input,
    expected,
    actual,
    notes: "Checks presence of every token category at least once.",
  });

  expected.has.forEach((k) => assert(types.includes(k as any), `Missing ${k} token`));
});

test("tokenize integer", () => {
  const input = "123;";
  const tokens = lexAll(input);
  const actual = { type: tokens[0].type, value: tokens[0].value };
  const expected = { type: "ENTIER", value: 123 };

  setTestContext({ input, expected, actual });
  assertEqual(actual, expected);
});

test("tokenize string", () => {
  const input = `"hello";`;
  const tokens = lexAll(input);
  const actual = { type: tokens[0].type, value: tokens[0].value };
  const expected = { type: "CHAINE", value: "hello" };

  setTestContext({ input, expected, actual });
  assertEqual(actual, expected);
});

// =========================
// PARSER TESTS
// =========================
test("parser - simple var declaration", () => {
  const input = "let x = 5;";
  const { ast, errors } = parse(input);
  const program = expectProgram(ast);
  const first = program.body[0];

  const actual = {
    parserErrors: errors.length,
    firstType: first?.type,
    varName: first && first.type === "VarDecl" ? first.name : undefined,
  };

  const expected = {
    parserErrors: 0,
    firstType: "VarDecl",
    varName: "x",
  };

  setTestContext({ input, expected, actual });
  assertEqual(actual, expected);
});

test("parser - missing semicolon should error (negative test)", () => {
  const input = "let x = 5";
  const { errors } = parse(input);

  const actual = { parserErrorCount: errors.length };
  const expected = { parserErrorCountAtLeast: 1 };

  setTestContext({
    input,
    expected,
    actual,
    notes: "Intentional wrong syntax to verify parser detects error.",
  });

  assert(errors.length > 0, "Expected parser error for missing semicolon");
});

// =========================
// SEMANTIC TESTS
// =========================
test("semantic - valid program", () => {
  const input = `
let x = 10;
repeat 3 { forward(5); }
`;
  const { semanticErrors } = runPipeline(input);

  const actual = { semanticErrors: semanticErrors.length };
  const expected = { semanticErrors: 0 };

  setTestContext({ input, expected, actual });
  assertEqual(actual, expected);
});

test("semantic - undefined variable (negative test)", () => {
  const input = `x = 5;`;
  const { semanticErrors } = runPipeline(input);

  const actual = {
    semanticErrors: semanticErrors.length,
    firstError: semanticErrors[0]?.message ?? null,
  };

  const expected = {
    semanticErrorsAtLeast: 1,
    contains: "Variable non définie",
  };

  setTestContext({
    input,
    expected,
    actual,
    notes: "Intentional semantic error: assignment before declaration.",
  });

  assert(semanticErrors.length > 0, "Expected semantic error for undefined variable");
  assert(
    (semanticErrors[0]?.message || "").includes("Variable non définie"),
    "Expected undefined variable message"
  );
});

test("semantic - division by zero (negative test)", () => {
  const input = `let x = 1 / 0;`;
  const { semanticErrors } = runPipeline(input);

  const actual = {
    semanticErrors: semanticErrors.length,
    firstError: semanticErrors[0]?.message ?? null,
  };

  const expected = {
    semanticErrorsAtLeast: 1,
    contains: "Division par zéro",
  };

  setTestContext({
    input,
    expected,
    actual,
    notes: "Intentional semantic error: division by zero.",
  });

  assert(semanticErrors.length > 0, "Expected semantic error for division by zero");
});

// =========================
// COMPLETE END TO END (E2E) TESTS
// =========================
test("complete - full pipeline success", () => {
  const input = `
let x = 5;
forward(x);
turn(90);
color("blue");
`;
  const { parserErrors, semanticErrors, state } = runPipeline(input);

  const actual = {
    parserErrors: parserErrors.length,
    semanticErrors: semanticErrors.length,
    finalColor: state.color,
  };

  const expected = {
    parserErrors: 0,
    semanticErrors: 0,
    finalColor: "blue",
  };

  setTestContext({ input, expected, actual });
  assertEqual(actual, expected);
});

test("complete - full pipeline fail (parser negative test)", () => {
  const input = `let x = ;`;
  const { parserErrors } = runPipeline(input);

  const actual = { parserErrors: parserErrors.length };
  const expected = { parserErrorsAtLeast: 1 };

  setTestContext({
    input,
    expected,
    actual,
    notes: "Intentional parser failure in full pipeline.",
  });

  assert(parserErrors.length > 0, "Expected parser errors");
});

test("complete - full pipeline fail (semantic negative test)", () => {
  const input = `forward("oops");`;
  const { semanticErrors } = runPipeline(input);

  const actual = {
    semanticErrors: semanticErrors.length,
    firstError: semanticErrors[0]?.message ?? null,
  };

  const expected = {
    semanticErrorsAtLeast: 1,
    containsOneOf: ["doit être un nombre", "Type invalide"],
  };

  setTestContext({
    input,
    expected,
    actual,
    notes: "Intentional semantic failure: wrong argument type.",
  });

  assert(semanticErrors.length > 0, "Expected semantic error");
});

// RUN ALL TESTS
run();