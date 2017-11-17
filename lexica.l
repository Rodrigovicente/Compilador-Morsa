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
BOOL "true"|"false"|"1"|"0"
ID {LETRA}({LETRA}|{NUM})*
STRING \"([^\"\n]|\\\")*\"

%%

"\n"		{}

{DELIM} 	{}


"int"|"float"|"char"|"bool"|"string"	{ yylval.label = yytext; yylval.tipo_var = yytext; return TK_TIPO; }

"var"	{ yylval.label = yytext; return TK_TIPO_INFERIDO; }

"(int)"|"(float)"|"(char)"		{ yylval.label = yytext; return TK_CAST; }

[(){}[\];,]	{ return *yytext; }

[+\-*/]		{ yylval.label = yytext; return TK_OP_ARI; }

"=="|"<"|"<="|">"|">="|"!="		{ yylval.label = yytext; return TK_OP_REL; }

"if"	{ yylval.label = yytext; return TK_COM_IF; }

"else"	{ yylval.label = yytext; return TK_COM_ELSE; }


"&&"|"||"|"!"	{yylval.label = yytext; return TK_OP_LOG;}

"print:"	{ yylval.label = yytext; return TK_PRINT; }


"="|"*="|"/="|"+="|"-="|"=="|"++"|"--"	{yylval.label = yytext; return TK_ATTR; }



{NUM}		{ yylval.label = yytext; yylval.tipo_var = "int"; return TK_NUM; }
{REAL}		{ yylval.label = yytext; yylval.tipo_var = "float"; return TK_REAL; }
{CHAR}		{ yylval.label = yytext; yylval.tipo_var = "char"; return TK_CHAR; }
{BOOL}		{ yylval.label = yytext; yylval.tipo_var = "bool"; return TK_BOOL; }
{ID}		{ yylval.label = yytext; return TK_ID; }
{STRING}    { yylval.label = yytext; yylval.tipo_var = "string"; return TK_STRING; }


.			{ *yytext; }

%%
