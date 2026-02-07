========================================================================
PROJET : INTERPRÉTEUR SQL SIMPLIFIÉ (GLSimpleSQL)
========================================================================

Module            : Théorie des Langages et Compilation (I513)
Auteur            : Abdelghani Salek
Email             : abdelghanisalek@gmail.com
Filière           : LST GL S5
Année Univ.       : 2025-2026
Date de rendu     : 03 December 2025

========================================================================
1. DESCRIPTION DU PROJET
========================================================================

Ce projet est un interpréteur pour le langage "GLSimpleSQL", développé en 
Langage C en utilisant les outils Flex (analyseur lexical) et Bison 
(analyseur syntaxique).

Conformément au cahier des charges, ce programme n'est pas un SGBD 
persistant. Son rôle est d'analyser les requêtes fournies en entrée pour :
1. Valider la syntaxe (CREATE, INSERT, SELECT, UPDATE, DELETE, DROP).
2. Effectuer des vérifications sémantiques strictes (existence des tables,
   typage, cohérence des valeurs).
3. Afficher des statistiques détaillées sur la structure de chaque requête.

========================================================================
2. CONTENU DU DOSSIER
========================================================================

Le code source est organisé de manière modulaire :

[Fichiers Sources]
* scanner.l         : Spécifications lexicales (Flex). Reconnaissance des 
                      tokens, insensibilité à la casse, gestion des 
                      commentaires et suivi des lignes.
* parser.y          : Spécifications syntaxiques (Bison). Grammaire BNF, 
                      gestion de la priorité des opérateurs (NOT > AND > OR)
                      et déclenchement des actions sémantiques.
* semantics.c       : Logique métier. Implémente la Table des Symboles 
                      (liste chaînée) et les fonctions de vérification.
* structures.h      : Fichier d'en-tête global. Définit les structures de
                      données (Table, Field) et les prototypes.
* main.c            : Point d'entrée du programme.

[Configuration & Tests]
* Makefile          : Script d'automatisation (compilation, run, clean).
* requetes_test.sql : Jeu de tests complet (scénarios nominaux et 
                      scénarios d'erreurs sémantiques).
* Grammaire.pdf     : Document formel décrivant la grammaire BNF.
* Rapport.pdf       : Rapport détaillé du projet.
* readMe.txt        : Ce fichier descriptif.

========================================================================
3. PRÉREQUIS ET INSTALLATION
========================================================================

Environnement recommandé : Linux (Ubuntu/Debian) ou macOS.
Outils nécessaires :
- GCC (GNU Compiler Collection)
- Flex
- Bison
- Make

========================================================================
4. COMPILATION ET EXÉCUTION
========================================================================

Le projet inclut un Makefile pour simplifier le processus.
Ouvrez un terminal dans la racine du projet :

A. COMPILATION
----------------
Pour générer l'exécutable nommé 'sql_interp' :

    $ make

B. EXÉCUTION DES TESTS
----------------------
Pour lancer l'interpréteur automatiquement avec le fichier de test fourni :

    $ make run

Alternativement, pour exécuter manuellement avec un autre fichier :

    $ ./sql_interp mon_fichier_test.sql

C. NETTOYAGE
------------
Pour supprimer les fichiers temporaires (.o, lex.yy.c, parser.tab.*) 
et l'exécutable (à exécuter avant de zipper le rendu) :

    $ make clean

========================================================================
5. FONCTIONNALITÉS IMPLÉMENTÉES
========================================================================

* Analyse Lexicale : 
  - Gestion des types (INT, FLOAT, VARCHAR, BOOL).
  - Gestion des commentaires SQL (--) et C (/* */).