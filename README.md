# BotScript IDE 🤖

**BotScript IDE** est un environnement de développement intégré (IDE) complet, basé sur le web, pour un langage spécifique au domaine (DSL) personnalisé conçu pour contrôler un robot virtuel. Ce projet a été développé comme mini-projet pour le cours de **Techniques de Compilation** à l'**GLSI - ISI (2024-2025)**.

L'objectif du projet est de démontrer l'application pratique des principes de construction de compilateurs : Analyse Lexicale, Analyse Syntaxique et Interprétation Sémantique.

---

## ⚡ Source de Vérité Unique : Implémentation TypeScript

> **L'implémentation autoritaire de ce projet est entièrement écrite en TypeScript.**
>
> Le fichier `src/compiler.ts` contient le **lexeur**, le **parseur** et l'**interpréteur** utilisés par l'IDE web. C'est le seul compilateur qui s'exécute réellement.
>
> Les fichiers dans `src/specs/` (`botscript.l`, `botscript.y`, `*.tab.c`, `lex.yy.c`) sont des **spécifications de référence / documentation illustrative** alignées sur les grammaires Flex/Bison vues en TP. Ils ne sont **pas compilés, pas exécutés** et ne font **pas partie du build Node/Vite**. Consultez [`src/specs/README.md`](src/specs/README.md) pour plus de détails.

---

## 🚀 Démarrage Rapide

1. **Installez Node.js** (v18 ou supérieure).
2. **Ouvrez un terminal** dans le dossier du projet.
3. **Installez les dépendances** :
   ```bash
   npm install
   ```
4. **Lancez le serveur de développement** :
   ```bash
   npm run dev
   ```
5. Ouvrez votre navigateur à l'URL affichée dans le terminal (généralement `http://localhost:3000`).

> ℹ️ Aucune étape de compilation C n'est nécessaire. Il n'y a aucun appel à `flex`, `bison` ou `gcc` dans les scripts du projet.

---

## 📁 Structure du Projet

```
Mini_projet-Compilation/
├── src/
│   ├── compiler.ts        ← ✅ SOURCE DE VÉRITÉ : Lexeur + Parseur + Interpréteur (TypeScript)
│   ├── App.tsx            ← Interface React (utilise uniquement compiler.ts)
│   ├── main.tsx           ← Point d'entrée React/Vite
│   ├── index.css          ← Styles globaux
│   └── specs/             ← 📚 RÉFÉRENCE SEULEMENT (ne pas compiler/exécuter)
│       ├── README.md          ← Explications des fichiers de spécification
│       ├── botscript.l        ← Grammaire Flex (référence documentaire)
│       ├── botscript.y        ← Grammaire Bison (référence documentaire)
│       ├── botscript.tab.h    ← En-tête généré par Bison (illustratif)
│       ├── botscript.tab.c    ← Code C généré par Bison (illustratif)
│       └── lex.yy.c           ← Code C généré par Flex (illustratif)
├── index.html
├── package.json           ← Scripts npm : dev, build, preview, lint (aucun appel C)
├── vite.config.ts
└── tsconfig.json
```

---

## 🛠️ Fonctionnement : Cohérence avec les TP (Flex & Bison)

Ce projet a été structuré pour être en cohérence pédagogique avec les travaux pratiques **TP1 (Analyse Lexicale)** et **TP2 (Analyse Syntaxique)**. L'implémentation TypeScript reproduit fidèlement les concepts Flex/Bison :

### 1. Analyse Lexicale (Inspirée de Flex) — `src/compiler.ts` classe `Lexer`
Le fichier `src/compiler.ts` implémente une méthode `yylex()` qui :
- Utilise des expressions régulières pour identifier les unités lexicales (`ENTIER`, `REEL`, `IDENT`, `MOTCLE`).
- Gère les variables globales standards : `yytext`, `yylval`, `yylineno`.
- Ignore les commentaires (`//` ou `#`) et les espaces, comme demandé dans le TP1.

### 2. Analyse Syntaxique (Inspirée de Bison) — `src/compiler.ts` classe `Parser`
La classe `Parser` implémente une méthode `yyparse()` qui :
- Suit une grammaire formelle définie par des règles de production.
- Gère les priorités des opérateurs (arithmétiques et relationnels).
- Effectue des actions sémantiques pour construire l'Arbre de Syntaxe Abstraite (AST).
- Supporte les boucles `while (condition) { ... }` et les boucles `repeat`.

### 3. Interprétation Sémantique — `src/compiler.ts` classe `Interpreter`
L'interpréteur parcourt l'AST et :
- Maintient un environnement de variables (table des symboles).
- Exécute les commandes robot (`forward`, `turn`, `color`, `penDown`, `penUp`).
- Détecte les erreurs sémantiques (variable non déclarée, etc.).

### 4. Fichiers de Spécifications (Référence Documentaire)
Pour votre rapport, les équivalents Flex/Bison sont fournis dans `src/specs/` à titre illustratif :
- `botscript.l` : Spécifications Flex (définitions régulières et règles de traduction).
- `botscript.y` : Spécifications Bison (grammaire complète incluant `while`, union `yylval` et actions).
- `botscript.tab.h` & `botscript.tab.c` : Fichiers d'en-tête et de code illustratifs (style Bison).
- `lex.yy.c` : Code C illustratif (style Flex).

Voir [`src/specs/README.md`](src/specs/README.md) pour les instructions si vous souhaitez compiler les fichiers C séparément à des fins académiques.

---

## 📝 Spécification du Langage

### Commandes de Base
| Commande | Description |
| :--- | :--- |
| `forward(dist);` | Déplace le robot vers l'avant de `dist` unités. |
| `turn(angle);` | Fait pivoter le robot de `angle` degrés (sens horaire). |
| `color("#hex");` | Définit la couleur du stylo (ex: `"#3b82f6"`). |
| `penDown();` | Abaisse le stylo pour commencer à dessiner. |
| `penUp();` | Lève le stylo pour arrêter de dessiner. |

### Logique et Flux de Contrôle
- **Variables** : `let size = 100;` ou `size = size + 10;`
- **Arithmétique** : Supporte `+`, `-`, `*`, `/` avec la priorité standard.
- **Boucles** : 
  - `repeat 4 { ... }` : Exécute le bloc un nombre fixe de fois.
  - `while (x < 100) { ... }` : Exécute le bloc tant que la condition est vraie.
- **Conditionnels** : `if (x > 10) { ... } else { ... }` pour la prise de décision.

---

## 🎨 Fonctionnalités de l'Interface Utilisateur

- **Éditeur style Monaco** : Un éditeur de code propre, au thème sombre, avec coloration syntaxique.
- **Onglet Compilateur (Visualisation Flex/Bison)** : Une vue exclusive permettant de voir :
  - **Flux de Jetons (yylex)** : La liste brute des tokens identifiés avec leurs types et valeurs.
  - **Structure AST (yyparse)** : L'arbre de syntaxe abstraite généré sous forme JSON pour comprendre la hiérarchie du code.
- **Visualiseur Canvas 2D** : Une grille en temps réel où le chemin du robot est dessiné.
- **Console Système** : Un outil de diagnostic qui affiche l'état de la compilation et les erreurs.
- **Panneau de Documentation** : Un guide intégré pour aider les utilisateurs à apprendre la syntaxe BotScript.

---

## 🎓 Contexte Éducatif
Ce projet sert d'implémentation pratique de :
- **Grammaires Formelles** : Définir la structure d'un langage.
- **Récupération d'Erreurs** : Gestion et signalement des erreurs à différentes étapes de la compilation.
- **Génération d'AST** : Transformer un texte plat en données structurées.
- **Machines Virtuelles** : Simuler un état de type matériel (le robot) via un logiciel.
