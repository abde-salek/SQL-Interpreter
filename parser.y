/* ================================================================== */
/* PARSER.Y : Analyseur Syntaxique et Sémantique pour GLSimpleSQL     */
/* ================================================================== */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "structures.h" 

/* --- Déclarations Externes --- */
extern int yylex();          // Fonction générée par Flex
extern int yylineno;         // Numéro de ligne courant (Flex)
extern char *yytext;         // Texte du token courant

/* --- Gestion d'erreurs --- */
void yyerror(const char *s);

/* --- Fonctions Sémantiques (définies dans semantics.c) --- */
extern Table *symbolTable;   // Tête de la liste des tables
int check_table_exists(char *name);
int check_field_exists(char *tableName, char *fieldName);
void add_table(char *name, Field *fields);
void drop_table_semantic(char *name);
int get_field_count(char *tableName);

/* --- Variables Globales pour le Context --- */
char current_table_name[100]; // Pour se souvenir de la table en cours (SELECT/UPDATE)
int  semantic_error_flag = 0; // Drapeau pour bloquer l'affichage si erreur
%}

/* ================================================================== */
/* DÉFINITION DE L'UNION (Types de valeurs possibles)                 */
/* ================================================================== */
%union {
    int ival;           // Pour les entiers et les compteurs (stats)
    float fval;         // Pour les réels
    char *sval;         // Pour les identifiants (noms) et chaînes
    struct Field *fld;  // Pour construire la liste des champs (CREATE)
}

/* ================================================================== */
/* DÉCLARATION DES TOKENS (Doit correspondre à scanner.l)             */
/* ================================================================== */

/* Mots-clés */
%token T_SELECT T_FROM T_WHERE T_INSERT T_INTO T_VALUES 
%token T_CREATE T_TABLE T_UPDATE T_SET T_DELETE T_DROP 
%token T_AND T_OR T_NOT 
%token T_INT T_FLOAT T_VARCHAR T_BOOL
%token T_TRUE T_FALSE

/* Opérateurs */
%token T_EQ T_NEQ T_LT T_GT T_LEQ T_GEQ 

/* Ponctuation */
%token T_SEMICOLON T_COMMA T_LPAREN T_RPAREN T_STAR

/* Valeurs typées */
%token <ival> T_INT_LIT
%token <fval> T_FLOAT_LIT
%token <sval> T_STRING_LIT T_ID

/* ================================================================== */
/* TYPAGE DES NON-TERMINAUX                                           */
/* ================================================================== */
%type <fld> field_def_list field_def
%type <ival> type_data
%type <ival> value_list field_list_select assignment_list field_list_names
%type <ival> condition condition_or condition_and condition_not condition_simple
%type <ival> where_clause_opt

/* ================================================================== */
/* RÈGLES DE PRÉCÉDENCE (Pour résoudre les conflits AND/OR)           */
/* ================================================================== */
/* On suit la logique SQL : NOT > AND > OR */
%left T_OR
%left T_AND
%right T_NOT

%%

/* ================================================================== */
/* GRAMMAIRE BNF                                                      */
/* ================================================================== */

program:
    statement_list
    ;

statement_list:
    statement_list statement
    | statement
    ;

statement:
    create_stmt T_SEMICOLON
    | insert_stmt T_SEMICOLON
    | select_stmt T_SEMICOLON
    | update_stmt T_SEMICOLON
    | delete_stmt T_SEMICOLON
    | drop_stmt T_SEMICOLON
    | error T_SEMICOLON { yyerrok; } /* Reprise sur erreur */
    ;

/* ------------------------------------------------------------------ */
/* 1. CREATE TABLE                                                    */
/* ------------------------------------------------------------------ */
create_stmt:
    T_CREATE T_TABLE T_ID T_LPAREN field_def_list T_RPAREN
    {
        /* Vérification sémantique : Table déjà existante ? */
        if(check_table_exists($3)) {
             fprintf(stderr, "ERREUR SÉMANTIQUE ligne %d : La table '%s' existe déjà.\n", yylineno, $3);
        } else {
             add_table($3, $5);
             printf("Requête CREATE analysée : Table '%s' créée avec succès.\n", $3);
        }
        free($3); // Libération du nom
    }
    ;

field_def_list:
    field_def T_COMMA field_def_list
    {
        $1->next = $3; /* Chaînage */
        $$ = $1;
    }
    | field_def
    {
        $$ = $1;
    }
    ;

field_def:
    T_ID type_data
    {
        struct Field *f = malloc(sizeof(struct Field));
        f->name = strdup($1);
        f->type = $2;
        f->next = NULL;
        $$ = f;
        free($1);
    }
    ;

type_data:
    T_INT                     { $$ = 1; /* Code pour INT */ }
    | T_FLOAT                 { $$ = 2; /* Code pour FLOAT */ }
    | T_BOOL                  { $$ = 3; /* Code pour BOOL */ }
    | T_VARCHAR T_LPAREN T_INT_LIT T_RPAREN { $$ = 4; /* Code pour VARCHAR */ }
    ;

/* ------------------------------------------------------------------ */
/* 2. INSERT INTO                                                     */
/* ------------------------------------------------------------------ */
insert_stmt:
    T_INSERT T_INTO T_ID T_VALUES T_LPAREN value_list T_RPAREN
    {
        if(!check_table_exists($3)) {
            fprintf(stderr, "ERREUR SÉMANTIQUE ligne %d : La table '%s' n'existe pas.\n", yylineno, $3);
        } else {
            int expected = get_field_count($3);
            if($6 != expected) {
                fprintf(stderr, "ERREUR SÉMANTIQUE ligne %d : INSERT INTO %s : %d valeurs fournies mais %d champs attendus.\n", 
                        yylineno, $3, $6, expected);
            } else {
                printf("Requête INSERT analysée :\n");
                printf(" - Table : %s\n", $3);
                printf(" - Nombre de valeurs : %d\n", $6);
                printf(" - Vérification : OK\n");
            }
        }
        free($3);
    }
    | T_INSERT T_INTO T_ID T_LPAREN field_list_select T_RPAREN T_VALUES T_LPAREN value_list T_RPAREN
    {
        /* Version avec liste de colonnes spécifiée */
        if(!check_table_exists($3)) {
            fprintf(stderr, "ERREUR SÉMANTIQUE ligne %d : La table '%s' n'existe pas.\n", yylineno, $3);
        } else {
            /* Vérifier cohérence colonnes / valeurs */
            if ($5 != $9) {
                fprintf(stderr, "ERREUR SÉMANTIQUE ligne %d : Incohérence, %d champs spécifiés pour %d valeurs.\n", yylineno, $5, $9);
            } else {
                printf("Requête INSERT (partiel) analysée :\n");
                printf(" - Table : %s\n", $3);
                printf(" - Valeurs insérées : %d\n", $9);
            }
        }
        free($3);
    }
    ;

value_list:
    value_list T_COMMA value_literal { $$ = $1 + 1; }
    | value_literal { $$ = 1; }
    ;

value_literal:
    T_INT_LIT | T_FLOAT_LIT | T_STRING_LIT | T_TRUE | T_FALSE
    ;

/* ------------------------------------------------------------------ */
/* 3. SELECT                                                          */
/* ------------------------------------------------------------------ */
select_stmt:
    T_SELECT field_list_select T_FROM T_ID where_clause_opt
    {
        semantic_error_flag = 0;
        /* Vérif Table */
        if(!check_table_exists($4)) {
            fprintf(stderr, "ERREUR SÉMANTIQUE ligne %d : La table '%s' n'existe pas.\n", yylineno, $4);
            semantic_error_flag = 1;
        }
        
        /* Si pas d'erreur, affichage des stats */
        if(!semantic_error_flag) {
            printf("----------------------------------\n");
            printf("Requête SELECT analysée :\n");
            printf(" - Table : %s\n", $4);
            if ($2 == -1) printf(" - Nombre de champs : TOUS (*)\n");
            else          printf(" - Nombre de champs : %d\n", $2);
            
            if ($5 == -1) {
                printf(" - Clause WHERE : NON\n");
            } else {
                printf(" - Clause WHERE : OUI\n");
                printf(" - Opérateurs logiques : %d\n", $5);
            }
            printf("----------------------------------\n");
        }
        free($4);
    }
    ;

field_list_select:
    T_STAR { $$ = -1; /* Code pour * */ }
    | field_list_names { $$ = $1; }
    ;

field_list_names:
    field_list_names T_COMMA T_ID 
    { 
        /* Ici on pourrait vérifier si T_ID existe dans la table, 
           mais la table est connue seulement APRES le FROM.
           Simplification pour ce projet : on compte juste. */
        $$ = $1 + 1; 
        free($3);
    }
    | T_ID 
    { 
        $$ = 1; 
        free($1);
    }
    ;

/* ------------------------------------------------------------------ */
/* 4. UPDATE                                                          */
/* ------------------------------------------------------------------ */
update_stmt:
    T_UPDATE T_ID T_SET assignment_list where_clause_opt
    {
        /* Sauvegarde nom table pour vérifs dans WHERE (via var globale si besoin) */
        if(!check_table_exists($2)) {
            fprintf(stderr, "ERREUR SÉMANTIQUE ligne %d : La table '%s' n'existe pas.\n", yylineno, $2);
        } else {
            printf("Requête UPDATE analysée :\n");
            printf(" - Table : %s\n", $2);
            printf(" - Champs modifiés : %d\n", $4);
            printf(" - Clause WHERE : %s\n", ($5 == -1 ? "NON" : "OUI"));
        }
        free($2);
    }
    ;

assignment_list:
    assignment_list T_COMMA assignment { $$ = $1 + 1; }
    | assignment { $$ = 1; }
    ;

assignment:
    T_ID T_EQ value_literal
    {
        /* Vérification simplifiée : on pourrait vérifier si T_ID existe */
        /* Note: Pour faire ça proprement, il faudrait connaître le nom de la table ici */
        free($1);
    }
    ;

/* ------------------------------------------------------------------ */
/* 5. DELETE                                                          */
/* ------------------------------------------------------------------ */
delete_stmt:
    T_DELETE T_FROM T_ID where_clause_opt
    {
        if(!check_table_exists($3)) {
            fprintf(stderr, "ERREUR SÉMANTIQUE ligne %d : La table '%s' n'existe pas.\n", yylineno, $3);
        } else {
            printf("Requête DELETE analysée :\n");
            printf(" - Table : %s\n", $3);
            printf(" - Clause WHERE : %s\n", ($4 == -1 ? "NON" : "OUI"));
        }
        free($3);
    }
    ;

/* ------------------------------------------------------------------ */
/* 6. DROP TABLE                                                      */
/* ------------------------------------------------------------------ */
drop_stmt:
    T_DROP T_TABLE T_ID
    {
        if(!check_table_exists($3)) {
            fprintf(stderr, "ERREUR SÉMANTIQUE ligne %d : Impossible de supprimer, la table '%s' n'existe pas.\n", yylineno, $3);
        } else {
            drop_table_semantic($3);
            printf("Requête DROP TABLE analysée : Table '%s' supprimée.\n", $3);
        }
        free($3);
    }
    ;

/* ------------------------------------------------------------------ */
/* CLAUSE WHERE ET CONDITIONS                                         */
/* ------------------------------------------------------------------ */

where_clause_opt:
    T_WHERE condition { $$ = $2; /* Retourne le nombre d'opérateurs logiques */ }
    | /* vide */      { $$ = -1; /* Code pour 'Pas de WHERE' */ }
    ;

/* Gestion de la précédence implicite via la grammaire ou %left */
condition:
    condition_or { $$ = $1; }
    ;

condition_or:
    condition_or T_OR condition_and { $$ = $1 + $3 + 1; } /* +1 pour le OR */
    | condition_and { $$ = $1; }
    ;

condition_and:
    condition_and T_AND condition_not { $$ = $1 + $3 + 1; } /* +1 pour le AND */
    | condition_not { $$ = $1; }
    ;

condition_not:
    T_NOT condition_simple { $$ = $2; } /* NOT ne compte pas comme op binaire stat */
    | condition_simple { $$ = $1; }
    ;

condition_simple:
    T_ID comparator value_literal 
    { 
        /* Vérification si le champ existe (Optional enhancement) 
           Pour ce projet, on retourne 0 car c'est une feuille (pas d'AND/OR ici) */
        free($1);
        $$ = 0; 
    }
    | T_LPAREN condition T_RPAREN { $$ = $2; }
    ;

comparator:
    T_EQ | T_NEQ | T_LT | T_GT | T_LEQ | T_GEQ 
    ;

%%

/* ================================================================== */
/* CODE C SUPPLÉMENTAIRE                                              */
/* ================================================================== */

void yyerror(const char *s) {
    fprintf(stderr, "ERREUR SYNTAXIQUE ligne %d : %s près de '%s'\n", yylineno, s, yytext);
}