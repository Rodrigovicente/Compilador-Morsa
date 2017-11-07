%{
#include <string>

%}

ESPACO [ \t]
DIGITO [0-9]
LETRA [A-Za-z_]

DELIM {ESPACO}+
NUM {DIGITO}+
REAL {NUM}+("."{NUM}+)?
CHAR \'({LETRA}|{NUM})\'
BOOL "true"|"false"
ID {LETRA}({LETRA}|{NUM})*

%%

"\n"		{}

{DELIM} 	{}

"main"		{return TK_MAIN;}

"int"		{return TK_TIPO_INT;}

"float"		{return TK_TIPO_FLOAT}

"char"		{return TK_TIPO_CHAR}

"bool"		{return TK_TIPO_BOOL}

"(int)"		{ yylval.label = yytext; return TK_CAST}

"(float)"	{ yylval.label = yytext; return TK_CAST}

"(char)"	{ yylval.label = yytext; return TK_CAST}

[(){}[\];,]	{ return *yytext; }

[+\-*/]		{ yylval.traducao = yytext; return TK_OP_MAT; }


"&&"|"and"	{return TK_OP_AND;}

"||"|"or"	{return TK_OP_OR;} 



{NUM}		{ yylval.label = yytext; yylval.tipo_var = "int"; return TK_NUM; }
{REAL}		{ yylval.label = yytext; yylval.tipo_var = "float"; return TK_REAL; }
{CHAR}		{ yylval.label = yytext; yylval.tipo_var = "char"; return TK_CHAR; }
{BOOL}		{ yylval.label = yytext; yylval.tipo_var = "bool"; return TK_BOOL; }
{ID}		{ yylval.label = yytext; return TK_ID; }

.			{ *yytext; }

%%
