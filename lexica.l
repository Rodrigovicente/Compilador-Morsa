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
STRING \"({LETRA}|{NUM})+\"

%%

"\n"		{}

{DELIM} 	{}

"int"|"float"|"char"|"bool"	{ yylval.label = yytext; return TK_TIPO; }

"var"	{ yylval.label = yytext; return TK_TIPO_INFERIDO; }

"(int)"|"(float)"|"(char)"		{ yylval.label = yytext; return TK_CAST; }

[(){}[\];,]	{ return *yytext; }

[+\-*/]		{ yylval.traducao = yytext; return TK_OP_ARI; }

"=="|"<"|"<="|">"|">="|"!="		{ yylval.traducao = yytext; return TK_OP_REL; }


"&&"|"||"|"!"	{return TK_OP_LOG;}



"="|"*="|"/="|"+="|"=="|"++"|"--"	{yylval.label = yytext; return TK_ATTR; }


{NUM}		{ yylval.label = yytext; yylval.tipo_var = "int"; return TK_NUM; }
{REAL}		{ yylval.label = yytext; yylval.tipo_var = "float"; return TK_REAL; }
{CHAR}		{ yylval.label = yytext; yylval.tipo_var = "char"; return TK_CHAR; }
{BOOL}		{ yylval.label = yytext; yylval.tipo_var = "bool"; return TK_BOOL; }
{ID}		{ yylval.label = yytext; return TK_ID; }
{STRING}    { yylval.label = yytext; yylval.tipo_var = "char*"; return TK_STRING; }

.			{ *yytext; }

%%
