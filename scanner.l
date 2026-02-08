%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

static char* sdup(const char *s) {
    if (!s) return NULL;
    size_t n = strlen(s);
    char *p = (char*)malloc(n + 1);
    if (!p) exit(1);
    memcpy(p, s, n + 1);
    return p;
}

static char* strdup_no_quotes(const char* s) {
    size_t len = strlen(s);
    if (len < 2) return sdup("");
    char* out = (char*)malloc(len - 1);
    if (!out) exit(1);
    memcpy(out, s + 1, len - 2);
    out[len - 2] = '\0';
    return out;
}
%}

%option noyywrap
%option yylineno
%option case-insensitive

DIGIT       [0-9]
INTEGER     -?{DIGIT}+
FLOAT       -?{DIGIT}+"."{DIGIT}+
ID          [a-zA-Z][a-zA-Z0-9_]*
STRING_SQ   \'([^'\n]|\\.)*\'
STRING_DQ   \"([^"\n]|\\.)*\"

%x COMMENT

%%

"--".*                      { }
"/*"                        { BEGIN(COMMENT); }
<COMMENT>"*/"               { BEGIN(INITIAL); }
<COMMENT>([^*]|\n)+|.       { }
<COMMENT><<EOF>>            { fprintf(stderr, "ERREUR LEXICALE ligne %d : Commentaire non termine\n", yylineno); return 0; }

\'([^'\n]|\\.)*             { fprintf(stderr, "ERREUR LEXICALE ligne %d : Chaine non terminee\n", yylineno); }
\"([^"\n]|\\.)*             { fprintf(stderr, "ERREUR LEXICALE ligne %d : Chaine non terminee\n", yylineno); }

"SELECT"                    { return T_SELECT; }
"FROM"                      { return T_FROM; }
"WHERE"                     { return T_WHERE; }
"INSERT"                    { return T_INSERT; }
"INTO"                      { return T_INTO; }
"VALUES"                    { return T_VALUES; }
"CREATE"                    { return T_CREATE; }
"TABLE"                     { return T_TABLE; }
"UPDATE"                    { return T_UPDATE; }
"SET"                       { return T_SET; }
"DELETE"                    { return T_DELETE; }
"DROP"                      { return T_DROP; }

"AND"                       { return T_AND; }
"OR"                        { return T_OR; }
"NOT"                       { return T_NOT; }

"INT"                       { return T_INT; }
"FLOAT"                     { return T_FLOAT; }
"VARCHAR"                   { return T_VARCHAR; }
"BOOL"                      { return T_BOOL; }

"TRUE"                      { return T_TRUE; }
"FALSE"                     { return T_FALSE; }

"!="                        { return T_NEQ; }
"<="                        { return T_LEQ; }
">="                        { return T_GEQ; }
"="                         { return T_EQ; }
"<"                         { return T_LT; }
">"                         { return T_GT; }

";"                         { return T_SEMICOLON; }
","                         { return T_COMMA; }
"("                         { return T_LPAREN; }
")"                         { return T_RPAREN; }
"*"                         { return T_STAR; }

{FLOAT}                     { yylval.fval = atof(yytext); return T_FLOAT_LIT; }
{INTEGER}                   { yylval.ival = atoi(yytext); return T_INT_LIT; }

{STRING_SQ}|{STRING_DQ}     { yylval.sval = strdup_no_quotes(yytext); return T_STRING_LIT; }

{ID}                        { yylval.sval = sdup(yytext); return T_ID; }

[ \t\r\n]+                  { }

.                           { fprintf(stderr, "ERREUR LEXICALE ligne %d : Caractere invalide '%s'\n", yylineno, yytext); }

%%