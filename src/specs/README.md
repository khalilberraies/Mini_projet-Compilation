# src/specs/ — Spécifications de Référence (Flex / Bison)

> ⚠️ **Ces fichiers sont fournis à titre de documentation et de référence académique uniquement.**
>
> Ils ne sont **pas compilés**, **pas exécutés** et **ne font pas partie du build** Node.js / Vite de l'IDE web.
> Le compilateur réellement utilisé par l'application est **`src/compiler.ts`** (TypeScript).

---

## Rôle de ce dossier

Ce dossier contient les équivalents **Flex** et **Bison** du compilateur TypeScript. Ils ont été produits pour :

1. **Illustrer** la correspondance directe entre l'implémentation TypeScript (`src/compiler.ts`) et les outils classiques du cours (TP1 Analyse Lexicale, TP2 Analyse Syntaxique).
2. **Servir de base** pour le rapport académique : grammaire formelle, règles de production, union `yylval`, etc.
3. **Permettre une compilation C optionnelle** à des fins d'expérimentation (voir section ci-dessous).

---

## Description des fichiers

| Fichier | Type | Description |
| :--- | :--- | :--- |
| `botscript.l` | Source Flex | Règles lexicales (équivalent de la classe `Lexer` dans `compiler.ts`) |
| `botscript.y` | Source Bison | Grammaire complète avec `while`, `repeat`, `if/else`, commandes (équivalent de la classe `Parser`) |
| `botscript.tab.h` | Illustratif (style Bison) | En-tête avec les tokens générés — à titre d'exemple |
| `botscript.tab.c` | Illustratif (style Bison) | Squelette du parseur C — à titre d'exemple |
| `lex.yy.c` | Illustratif (style Flex) | Squelette du lexeur C — à titre d'exemple |

---

## Correspondance avec l'implémentation TypeScript

| Concept | Fichier C/Flex/Bison | Équivalent TypeScript (`src/compiler.ts`) |
| :--- | :--- | :--- |
| Analyse lexicale | `botscript.l` + `lex.yy.c` | Classe `Lexer` → méthode `yylex()` |
| Analyse syntaxique | `botscript.y` + `botscript.tab.c` | Classe `Parser` → méthode `yyparse()` |
| Table des symboles / sémantique | Actions dans `.y` | Classe `Interpreter` → méthode `execute()` |
| Rapport d'erreur | `yyerror()` dans `.y` | Méthode `yyerror()` dans `Lexer` et `Parser` |
| Variables globales Flex | `yytext`, `yylineno`, `yylval` | Variables globales exportées dans `compiler.ts` |

---

## Compilation C optionnelle (expérimentation académique)

Si vous souhaitez compiler et tester la version C avec les vrais outils Flex/Bison :

```bash
# Pré-requis : flex et bison installés (ex: sudo apt install flex bison)
cd src/specs/

# 1. Générer le parseur depuis la grammaire Bison
bison -d botscript.y          # génère botscript.tab.c et botscript.tab.h

# 2. Générer le lexeur depuis les spécifications Flex
flex botscript.l               # génère lex.yy.c

# 3. Compiler l'ensemble
gcc -o botscript botscript.tab.c lex.yy.c -lfl

# 4. Exécuter sur un fichier BotScript
./botscript < monprogramme.bs
```

> **Note :** Ces étapes sont **entièrement séparées** du projet Node/Vite et n'ont aucun impact sur `npm run dev` ou `npm run build`.

---

## Pourquoi deux implémentations ?

Ce projet est un mini-projet académique visant à démontrer les principes de compilation à deux niveaux :

- **Niveau théorique** : grammaire formelle Flex/Bison (ce dossier) — proche des outils vus en TP.
- **Niveau pratique** : implémentation TypeScript (`src/compiler.ts`) — intégrée dans l'IDE web React/Vite.

L'implémentation TypeScript est la **source de vérité unique** pour toutes les fonctionnalités décrites dans le README principal. En cas de divergence entre `botscript.y` et `compiler.ts`, c'est **`compiler.ts` qui fait référence**.
