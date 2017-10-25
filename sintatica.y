%{
#include <iostream>
#include <string>
#include <sstream>

#define YYSTYPE atributos

using namespace std;

int yylex(void);
void yyerror(string);

struct atributos
{
	string label;
	string traducao;
	string tipo_var;
	string nome_var;
};

	static int count_vars = 0;
	static int count_tmps = 0;

	static vector<atributos> mapaVariaveis;


	bool mapaContemVar(atributos variavel){
		
		bool result = false;
		int i;

		for(i = 0; i < mapaVariaveis.size(); i++){
			if(mapaVariaveis[i].nome_var == variavel.nome_var){
				result = true;
			}
		}

		return result;
	}

	string cria_nome_var(){
		ostringstream convert;
		convert << count_vars;

		string nome = "var"+convert.str();
		return nome;
	}

	string cria_nome_tmp(){
		ostringstream convert;
		convert << count_tmps;

		string nome = "tmp"+convert.str();
		return nome;
	}




%}

%token TK_NUM
%token TK_CHAR
%token TK_BOOL
%token TK_MAIN TK_ID TK_TIPO_INT
%token TK_FIM TK_ERROR

%start S

%left '+'

%%

S 			: TK_TIPO_INT TK_MAIN '(' ')' BLOCO
			{
				cout << "/*Compilador FOCA*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << $5.traducao << "\treturn 0;\n}" << endl; 
			}
			;

BLOCO		: '{' COMANDOS '}'
			{
				$$.traducao = $2.traducao;
			}
			;

COMANDOS	: COMANDO COMANDOS
			{

			}
			;

COMANDO 	: E ';'
			{

			}
			;

E 			: E '+' E
			{
				$$.traducao = $1.traducao + $3.traducao + "\ta = b + c;\n";
			}
			| TK_NUM
			{
				$$.traducao = "\ta = " + $1.traducao + ";\n";
			}
			| TK_ID
			;

%%

#include "lex.yy.c"

int yyparse();

int main( int argc, char* argv[] )
{
	yyparse();

	return 0;
}

void yyerror( string MSG )
{
	cout << MSG << endl;
	exit (0);
}				
