/* A Bison parser, made by GNU Bison 3.7.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    T_SELECT = 258,                /* T_SELECT  */
    T_FROM = 259,                  /* T_FROM  */
    T_WHERE = 260,                 /* T_WHERE  */
    T_INSERT = 261,                /* T_INSERT  */
    T_INTO = 262,                  /* T_INTO  */
    T_VALUES = 263,                /* T_VALUES  */
    T_CREATE = 264,                /* T_CREATE  */
    T_TABLE = 265,                 /* T_TABLE  */
    T_UPDATE = 266,                /* T_UPDATE  */
    T_SET = 267,                   /* T_SET  */
    T_DELETE = 268,                /* T_DELETE  */
    T_DROP = 269,                  /* T_DROP  */
    T_AND = 270,                   /* T_AND  */
    T_OR = 271,                    /* T_OR  */
    T_NOT = 272,                   /* T_NOT  */
    T_INT = 273,                   /* T_INT  */
    T_FLOAT = 274,                 /* T_FLOAT  */
    T_VARCHAR = 275,               /* T_VARCHAR  */
    T_BOOL = 276,                  /* T_BOOL  */
    T_TRUE = 277,                  /* T_TRUE  */
    T_FALSE = 278,                 /* T_FALSE  */
    T_EQ = 279,                    /* T_EQ  */
    T_NEQ = 280,                   /* T_NEQ  */
    T_LT = 281,                    /* T_LT  */
    T_GT = 282,                    /* T_GT  */
    T_LEQ = 283,                   /* T_LEQ  */
    T_GEQ = 284,                   /* T_GEQ  */
    T_SEMICOLON = 285,             /* T_SEMICOLON  */
    T_COMMA = 286,                 /* T_COMMA  */
    T_LPAREN = 287,                /* T_LPAREN  */
    T_RPAREN = 288,                /* T_RPAREN  */
    T_STAR = 289,                  /* T_STAR  */
    T_INT_LIT = 290,               /* T_INT_LIT  */
    T_FLOAT_LIT = 291,             /* T_FLOAT_LIT  */
    T_STRING_LIT = 292,            /* T_STRING_LIT  */
    T_ID = 293                     /* T_ID  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 35 "parser.y"

    int ival;           // Pour les entiers et les compteurs (stats)
    float fval;         // Pour les réels
    char *sval;         // Pour les identifiants (noms) et chaînes
    struct Field *fld;  // Pour construire la liste des champs (CREATE)

#line 109 "parser.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */
