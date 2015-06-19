%define api.pure full
%lex-param {void *scanner}
%parse-param {void *scanner}{ast_node_sexp **node}

%define parse.trace
%define parse.error verbose

%{
#include <stdio.h>
#include "ast.h"
#include "parser.tab.h"
#include "scanner.h"

void yyerror (yyscan_t *locp, ast_node_sexp **node, char const *msg);
%}

%code requires
{
#include "ast.h"
}

%define api.value.type union /* Generate YYSTYPE from these types:  */
%token <long>     NUMBER     "number"
%token <char *>   STRING     "string"
%token <char *>   IDENTIFIER "identifier"

%token TOK_EOF 0 "end of file"
%token TOK_LPAREN "("
%token TOK_RPAREN ")"

%type <ast_node_sexp*> sexp
%type <ast_node_atom*> atom
%type <struct ast_node_list*> list

%%
%start sexps;

sexps:
	sexp        { *node = $1; }

sexp:
  atom          { $$ = new_sexp_node(ST_ATOM, $1); }
| "(" list ")"  { $$ = new_sexp_node(ST_LIST, $2); };

list:
  %empty        { $$ = new_list_node(); }
| list sexp     { $$ = $1; add_node_to_list($$, $2); };

atom:
  "number"      { $$ = new_atom_node(AT_NUMBER, (void *)(&$1)); }
| "identifier"  { $$ = new_atom_node(AT_IDENTIFIER, (void *)(&$1)); }
| "string"      { $$ = new_atom_node(AT_STRING, (void *)(&$1)); };

%%

void yyerror (yyscan_t *locp, ast_node_sexp **node, char const *msg) {
	fprintf(stderr, "--> %s\n", msg);
}

