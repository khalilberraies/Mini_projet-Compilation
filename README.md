# BotScript IDE 🤖

**BotScript IDE** est un environnement de développement intégré (IDE) complet, basé sur le web, pour un langage spécifique au domaine (DSL) personnalisé conçu pour contrôler un robot virtuel. Ce projet a été développé comme mini-projet pour le cours de **Techniques de Compilation** à l'**GLSI - ISI (2024-2025)**.

L'objectif du projet est de démontrer l'application pratique des principes de construction de compilateurs : Analyse Lexicale, Analyse Syntaxique et Interprétation Sémantique.

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

---

## 🛠️ Fonctionnement : Cohérence avec les TP (Flex & Bison)

Ce projet a été restructuré pour être en parfaite cohérence avec les travaux pratiques **TP1 (Analyse Lexicale)** et **TP2 (Analyse Syntaxique)** :

### 1. Analyse Lexicale (Inspirée de Flex)
Le fichier `src/compiler.ts` implémente une fonction `yylex()` qui :
- Utilise des expressions régulières pour identifier les unités lexicales (`ENTIER`, `REEL`, `IDENT`, `MOTCLE`).
- Gère les variables globales standards : `yytext`, `yylval`, `yylineno`.
- Ignore les commentaires (`//` ou `#`) et les espaces, comme demandé dans le TP1.

### 2. Analyse Syntaxique (Inspirée de Bison)
La classe `Parser` implémente une méthode `yyparse()` qui :
- Suit une grammaire formelle définie par des règles de production.
- Gère les priorités des opérateurs (arithmétiques et relationnels).
- Effectue des actions sémantiques pour construire l'Arbre de Syntaxe Abstraite (AST).
- Supporte désormais les boucles `while (condition) { ... }` en plus des boucles `repeat`.

### 3. Fichiers de Spécifications et Fichiers Générés
Pour votre rapport, les fichiers sources et les fichiers générés théoriques sont fournis dans le dossier `src/specs/` :
- `botscript.l` : Spécifications Flex (définitions régulières et règles de traduction).
- `botscript.y` : Spécifications Bison (grammaire, union yylval et actions).
- `botscript.tab.h` & `botscript.tab.c` : Fichiers d'en-tête et de code générés par Bison.
- `lex.yy.c` : Code C généré par Flex pour l'analyseur lexical.

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
