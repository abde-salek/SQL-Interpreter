%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "structures.h"

#ifndef GLSIMPLESQL_AST_TYPES
#define GLSIMPLESQL_AST_TYPES

typedef struct StrList {
    char *s;
    struct StrList *next;
} StrList;

typedef struct CondInfo {
    int predicates;
    int ands;
    int ors;
} CondInfo;

typedef struct WhereInfo {
    int has_where;
    CondInfo c;
} WhereInfo;

typedef struct SelectInfo {
    int has_star;
    int mixed_star;
    StrList *cols;
    int col_count;
} SelectInfo;

typedef struct AssignInfo {
    StrList *cols;
    int count;
} AssignInfo;

#endif

int yylex(void);
void yyerror(const char *s);
extern int yylineno;

static char* sdup(const char *s) {
    if (!s) return NULL;
    size_t n = strlen(s);
    char *p = (char*)malloc(n + 1);
    if (!p) exit(1);
    memcpy(p, s, n + 1);
    return p;
}

static void free_strlist(StrList *l) {
    while (l) {
        StrList *n = l->next;
        free(l->s);
        free(l);
        l = n;
    }
}

static StrList* sl_cons(char *s, StrList *tail) {
    StrList *n = (StrList*)malloc(sizeof(StrList));
    if (!n) exit(1);
    n->s = s;
    n->next = tail;
    return n;
}

static int sl_len(StrList *l) {
    int c = 0;
    while (l) { c++; l = l->next; }
    return c;
}

static int sl_contains(StrList *l, const char *s) {
    while (l) {
        if (strcmp(l->s, s) == 0) return 1;
        l = l->next;
    }
    return 0;
}

static Field* make_field(char *name, int type, int varchar_len) {
    Field *f = (Field*)malloc(sizeof(Field));
    if (!f) exit(1);
    f->name = name;
    f->type = type;
    f->varchar_len = varchar_len;
    f->next = NULL;
    return f;
}

static Field* field_append(Field *list, Field *node) {
    if (!list) return node;
    Field *c = list;
    while (c->next) c = c->next;
    c->next = node;
    return list;
}

static void semantic_error(const char *msg) {
    fprintf(stderr, "ERREUR SEMANTIQUE ligne %d : %s\n", yylineno, msg);
}

static void print_select_stats(const char *table, SelectInfo si, WhereInfo wi) {
    printf("TYPE=SELECT TABLE=%s ", table);
    if (si.has_star && !si.mixed_star) printf("CHAMPS=* ");
    else if (si.mixed_star) printf("CHAMPS=MIXTE ");
    else printf("NB_CHAMPS=%d ", si.col_count);
    printf("WHERE=%s ", wi.has_where ? "OUI" : "NON");
    if (wi.has_where) {
        printf("NB_CONDITIONS=%d NB_AND=%d NB_OR=%d", wi.c.predicates, wi.c.ands, wi.c.ors);
    } else {
        printf("NB_CONDITIONS=0 NB_AND=0 NB_OR=0");
    }
    printf("\n");
}

static void print_insert_stats(const char *table, int nbVals, int hasCols, int nbCols) {
    printf("TYPE=INSERT TABLE=%s VALEURS=%d COLONNES=%s NB_COLONNES=%d\n",
           table, nbVals, hasCols ? "OUI" : "NON", hasCols ? nbCols : 0);
}

static void print_update_stats(const char *table, int nbAssign, WhereInfo wi) {
    printf("TYPE=UPDATE TABLE=%s NB_AFFECT=%d WHERE=%s ",
           table, nbAssign, wi.has_where ? "OUI" : "NON");
    if (wi.has_where) {
        printf("NB_CONDITIONS=%d NB_AND=%d NB_OR=%d", wi.c.predicates, wi.c.ands, wi.c.ors);
    } else {
        printf("NB_CONDITIONS=0 NB_AND=0 NB_OR=0");
    }
    printf("\n");
}

static void print_delete_stats(const char *table, WhereInfo wi) {
    printf("TYPE=DELETE TABLE=%s WHERE=%s ",
           table, wi.has_where ? "OUI" : "NON");
    if (wi.has_where) {
        printf("NB_CONDITIONS=%d NB_AND=%d NB_OR=%d", wi.c.predicates, wi.c.ands, wi.c.ors);
    } else {
        printf("NB_CONDITIONS=0 NB_AND=0 NB_OR=0");
    }
    printf("\n");
}

static void print_create_stats(const char *table, int nbCols) {
    printf("TYPE=CREATE TABLE=%s NB_COLONNES=%d\n", table, nbCols);
}

static void print_drop_stats(const char *table) {
    printf("TYPE=DROP TABLE=%s\n", table);
}

static void check_columns_exist(const char *table, StrList *cols) {
    StrList *c = cols;
    while (c) {
        if (!check_field_exists(table, c->s)) {
            char buf[256];
            snprintf(buf, sizeof(buf), "Champ inexistant '%s'", c->s);
            semantic_error(buf);
        }
        c = c->next;
    }
}

static void check_columns_unique(StrList *cols) {
    for (StrList *a = cols; a; a = a->next) {
        for (StrList *b = a->next; b; b = b->next) {
            if (strcmp(a->s, b->s) == 0) {
                semantic_error("Liste de colonnes contient des doublons");
                return;
            }
        }
    }
}

static void check_fields_unique(Field *fields) {
    for (Field *a = fields; a; a = a->next) {
        for (Field *b = a->next; b; b = b->next) {
            if (strcmp(a->name, b->name) == 0) {
                semantic_error("Colonnes en double dans CREATE TABLE");
                return;
            }
        }
    }
}

static void check_operand_id(const char *table, const char *maybeId, int isId) {
    if (!isId) return;
    if (!check_field_exists(table, maybeId)) {
        char buf[256];
        snprintf(buf, sizeof(buf), "Champ inexistant '%s'", maybeId);
        semantic_error(buf);
    }
}
%}

%code requires {
#ifndef GLSIMPLESQL_AST_TYPES
#define GLSIMPLESQL_AST_TYPES

#include "structures.h"

typedef struct StrList {
    char *s;
    struct StrList *next;
} StrList;

typedef struct CondInfo {
    int predicates;
    int ands;
    int ors;
} CondInfo;

typedef struct WhereInfo {
    int has_where;
    CondInfo c;
} WhereInfo;

typedef struct SelectInfo {
    int has_star;
    int mixed_star;
    StrList *cols;
    int col_count;
} SelectInfo;

typedef struct AssignInfo {
    StrList *cols;
    int count;
} AssignInfo;

#endif
}

%union {
    int ival;
    double fval;
    char *sval;
    Field *fieldp;
    StrList *slist;
    CondInfo cinfo;
    WhereInfo winfo;
    SelectInfo sinfo;
    AssignInfo ainfo;
    int dtype;
    int count;
}

%token T_SELECT T_FROM T_WHERE T_INSERT T_INTO T_VALUES T_CREATE T_TABLE T_UPDATE T_SET T_DELETE T_DROP
%token T_AND T_OR T_NOT
%token T_INT T_FLOAT T_VARCHAR T_BOOL
%token T_TRUE T_FALSE
%token T_EQ T_NEQ T_LT T_GT T_LEQ T_GEQ
%token T_SEMICOLON T_COMMA T_LPAREN T_RPAREN T_STAR
%token <sval> T_ID
%token <ival> T_INT_LIT
%token <fval> T_FLOAT_LIT
%token <sval> T_STRING_LIT

%type <dtype> type_spec
%type <fieldp> col_def col_def_list
%type <slist> id_list opt_id_list value_list
%type <count> opt_varchar_len
%type <count> value
%type <cinfo> condition predicate
%type <winfo> where_opt
%type <sinfo> select_list
%type <ainfo> assign_list assign

%start program

%%

program
    : stmts
    ;

stmts
    : stmts stmt
    | stmt
    ;

stmt
    : create_stmt
    | insert_stmt
    | select_stmt
    | update_stmt
    | delete_stmt
    | drop_stmt
    ;

create_stmt
    : T_CREATE T_TABLE T_ID T_LPAREN col_def_list T_RPAREN T_SEMICOLON
      {
        char *table = $3;
        Field *fields = $5;
        int nbCols = 0;
        for (Field *f = fields; f; f = f->next) nbCols++;
        if (check_table_exists(table)) {
            semantic_error("Table deja existante");
            free(table);
            free_fields(fields);
        } else {
            check_fields_unique(fields);
            if (!add_table(table, fields)) {
                semantic_error("Echec ajout table (doublons possibles)");
                free_fields(fields);
            } else {
                print_create_stats(table, nbCols);
            }
            free(table);
        }
      }
    ;

col_def_list
    : col_def_list T_COMMA col_def
      { $$ = field_append($1, $3); }
    | col_def
      { $$ = $1; }
    ;

col_def
    : T_ID type_spec opt_varchar_len
      { $$ = make_field($1, $2, $3); }
    ;

type_spec
    : T_INT     { $$ = TYPE_INT; }
    | T_FLOAT   { $$ = TYPE_FLOAT; }
    | T_BOOL    { $$ = TYPE_BOOL; }
    | T_VARCHAR { $$ = TYPE_VARCHAR; }
    ;

opt_varchar_len
    : T_LPAREN T_INT_LIT T_RPAREN { $$ = $2; }
    |                             { $$ = 0; }
    ;

insert_stmt
    : T_INSERT T_INTO T_ID opt_id_list T_VALUES T_LPAREN value_list T_RPAREN T_SEMICOLON
      {
        char *table = $3;
        StrList *cols = $4;
        int nbVals = sl_len($7);
        int hasCols = cols != NULL;
        int nbCols = hasCols ? sl_len(cols) : 0;

        if (!check_table_exists(table)) {
            semantic_error("Table inexistante");
        } else {
            if (hasCols) {
                check_columns_unique(cols);
                check_columns_exist(table, cols);
                if (nbCols != nbVals) semantic_error("Incoherence INSERT : nb colonnes != nb valeurs");
            } else {
                int expected = get_field_count(table);
                if (expected != nbVals) semantic_error("Incoherence INSERT : nb champs table != nb valeurs");
            }
            print_insert_stats(table, nbVals, hasCols, nbCols);
        }

        free(table);
        free_strlist(cols);
        free_strlist($7);
      }
    ;

opt_id_list
    : T_LPAREN id_list T_RPAREN { $$ = $2; }
    |                           { $$ = NULL; }
    ;

value_list
    : value_list T_COMMA value  { $$ = sl_cons(sdup("v"), $1); }
    | value                     { $$ = sl_cons(sdup("v"), NULL); }
    ;

value
    : T_INT_LIT      { $$ = 1; }
    | T_FLOAT_LIT    { $$ = 1; }
    | T_STRING_LIT   { free($1); $$ = 1; }
    | T_TRUE         { $$ = 1; }
    | T_FALSE        { $$ = 1; }
    ;

select_stmt
    : T_SELECT select_list T_FROM T_ID where_opt T_SEMICOLON
      {
        SelectInfo si = $2;
        char *table = $4;
        WhereInfo wi = $5;

        if (!check_table_exists(table)) {
            semantic_error("Table inexistante");
        } else {
            if (si.mixed_star) {
                semantic_error("Utilisation invalide de * avec des champs");
            }
            if (!si.has_star) {
                check_columns_unique(si.cols);
                check_columns_exist(table, si.cols);
            }
            if (wi.has_where) {
                CondInfo ci = wi.c;
                (void)ci;
            }
        }

        print_select_stats(table, si, wi);

        free(table);
        free_strlist(si.cols);
      }
    ;

select_list
    : T_STAR
      { $$ = (SelectInfo){1, 0, NULL, 0}; }
    | id_list
      { $$ = (SelectInfo){0, 0, $1, sl_len($1)}; }
    | T_STAR T_COMMA id_list
      { $$ = (SelectInfo){1, 1, $3, sl_len($3)}; }
    ;

id_list
    : id_list T_COMMA T_ID
      { $$ = sl_cons($3, $1); }
    | T_ID
      { $$ = sl_cons($1, NULL); }
    ;

where_opt
    : T_WHERE condition
      { $$ = (WhereInfo){1, $2}; }
    | 
      { $$ = (WhereInfo){0, (CondInfo){0,0,0}}; }
    ;

condition
    : condition T_AND predicate
      { $$ = (CondInfo){$1.predicates + $3.predicates, $1.ands + 1 + $3.ands, $1.ors + $3.ors}; }
    | condition T_OR predicate
      { $$ = (CondInfo){$1.predicates + $3.predicates, $1.ands + $3.ands, $1.ors + 1 + $3.ors}; }
    | predicate
      { $$ = $1; }
    ;

predicate
    : opt_not operand comp_op operand
      { $$ = (CondInfo){1,0,0}; }
    ;

opt_not
    : T_NOT
    |
    ;

comp_op
    : T_EQ
    | T_NEQ
    | T_LT
    | T_GT
    | T_LEQ
    | T_GEQ
    ;

operand
    : T_ID
      { free($1); }
    | T_INT_LIT
    | T_FLOAT_LIT
    | T_STRING_LIT
      { free($1); }
    | T_TRUE
    | T_FALSE
    ;

update_stmt
    : T_UPDATE T_ID T_SET assign_list where_opt T_SEMICOLON
      {
        char *table = $2;
        AssignInfo ai = $4;
        WhereInfo wi = $5;

        if (!check_table_exists(table)) {
            semantic_error("Table inexistante");
        } else {
            check_columns_unique(ai.cols);
            check_columns_exist(table, ai.cols);
        }

        print_update_stats(table, ai.count, wi);

        free(table);
        free_strlist(ai.cols);
      }
    ;

assign_list
    : assign_list T_COMMA assign
      {
        AssignInfo a = $1;
        a.cols = sl_cons($3.cols->s, a.cols);
        free($3.cols);
        a.count += 1;
        $$ = a;
      }
    | assign
      { $$ = $1; }
    ;

assign
    : T_ID T_EQ value
      {
        AssignInfo a;
        a.cols = sl_cons($1, NULL);
        a.count = 1;
        $$ = a;
      }
    ;

delete_stmt
    : T_DELETE T_FROM T_ID where_opt T_SEMICOLON
      {
        char *table = $3;
        WhereInfo wi = $4;

        if (!check_table_exists(table)) {
            semantic_error("Table inexistante");
        }

        print_delete_stats(table, wi);

        free(table);
      }
    ;

drop_stmt
    : T_DROP T_TABLE T_ID T_SEMICOLON
      {
        char *table = $3;
        if (!drop_table_semantic(table)) {
            semantic_error("Table inexistante");
        } else {
            print_drop_stats(table);
        }
        free(table);
      }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "ERREUR SYNTAXIQUE ligne %d : %s\n", yylineno, s);
}