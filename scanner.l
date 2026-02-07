/* ================================================================== */
/* SCANNER.L : Analyseur Lexical pour GLSimpleSQL                     */
/* ================================================================== */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h" /* Inclure les tokens définis par Bison */

/* Fonction utilitaire pour copier les chaînes sans les guillemets */
char* strdup_no_quotes(const char* s) {
    size_t len = strlen(s);
    if (len < 2) return strdup("");
    char* new_str = (char*)malloc(len - 1);
    strncpy(new_str, s + 1, len - 2);
    new_str[len - 2] = '\0';
    return new_str;
}
%}

/* Options Flex */
%option noyywrap
%option yylineno
%option case-insensitive

/* Définitions régulières */
DIGIT       [0-9]
INTEGER     {DIGIT}+
FLOAT       {DIGIT}+"."{DIGIT}+
ID          [a-zA-Z][a-zA-Z0-9_]*
STRING_SQ   \'([^'\n]|\\.)*\'
STRING_DQ   \"([^"\n]|\\.)*\"

/* État exclusif pour les commentaires multi-lignes */
%x COMMENT

%%

    /* --- 1. Gestion des Commentaires --- */
"--".*                  { /* Ignorer commentaire mono-ligne */ }

"/*"                    { BEGIN(COMMENT); }
<COMMENT>"*/"           { BEGIN(INITIAL); }
<COMMENT>([^*]|\n)+|.   { /* Ignorer le contenu du commentaire */ }
<COMMENT><<EOF>>        { fprintf(stderr, "Erreur: Commentaire non terminé\n"); return 0; }

    /* --- 2. Mots-clés SQL (Insensible à la casse grâce à l'option) --- */
"SELECT"    { return T_SELECT; }
"FROM"      { return T_FROM; }
"WHERE"     { return T_WHERE; }
"INSERT"    { return T_INSERT; }
"INTO"      { return T_INTO; }
"VALUES"    { return T_VALUES; }
"CREATE"    { return T_CREATE; }
"TABLE"     { return T_TABLE; }
"UPDATE"    { return T_UPDATE; }
"SET"       { return T_SET; }
"DELETE"    { return T_DELETE; }
"DROP"      { return T_DROP; }

"AND"       { return T_AND; }
"OR"        { return T_OR; }
"NOT"       { return T_NOT; }

"INT"       { return T_INT; }
"FLOAT"     { return T_FLOAT; }
"VARCHAR"   { return T_VARCHAR; }
"BOOL"      { return T_BOOL; }

"TRUE"      { return T_TRUE; }
"FALSE"     { return T_FALSE; }

    /* --- 3. Opérateurs et Ponctuation --- */
"="         { return T_EQ; } /* Peut aussi renvoyer '=' selon parser */
"!="        { return T_NEQ; }
"<"         { return T_LT; }
">"         { return T_GT; }
"<="        { return T_LEQ; }
">="        { return T_GEQ; }

";"         { return T_SEMICOLON; }
","         { return T_COMMA; }
"("         { return T_LPAREN; }
")"         { return T_RPAREN; }
"*"         { return T_STAR; }

    /* --- 4. Constantes et Identificateurs --- */

{INTEGER} {
    yylval.ival = atoi(yytext);
    return T_INT_LIT;
}

{FLOAT} {
    yylval.fval = atof(yytext);
    return T_FLOAT_LIT;
}

{STRING_SQ}|{STRING_DQ} {
    /* On retire les guillemets avant d'envoyer au parser */
    yylval.sval = strdup_no_quotes(yytext);
    return T_STRING_LIT;
}

{ID} {
    /* Important : Dupliquer la chaîne car yytext est écrasé ensuite */
    yylval.sval = strdup(yytext);
    return T_ID;
}

    /* --- 5. Gestion des Espaces et Erreurs --- */

[ \t\r\n]+  { /* Ignorer les espaces blancs */ }

. {
    fprintf(stderr, "ERREUR LEXICALE ligne %d : Caractère invalide '%s'\n", yylineno, yytext);
    /* On ne retourne pas forcément pour tenter de continuer l'analyse */
}

%%