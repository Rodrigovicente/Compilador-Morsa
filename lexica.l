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

"(int)"		{return TK_CAST}

"(float)"	{return TK_CAST}

"(char)"	{return TK_CAST}

[(){}[\];,]	{ return *yytext; }

[+\-*/]		{ return *yytext; }


"&&"|"and"	{return TK_OP_AND;}

"||"|"or"	{return TK_OP_OR;} 



{NUM}		{ yylval.traducao = yytext; return TK_NUM; }
{REAL}		{ yylval.traducao = yytext; return TK_REAL; }
{CHAR}		{ yylval.traducao = yytext; return TK_CHAR; }
{BOOL}		{ yylval.traducao = yytext; return TK_BOOL; }
{ID}		{ yylval.label = yytext; return TK_ID; }

.			{ *yytext; }

%%
