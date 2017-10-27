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

	vector<atributos> mapaVariaveis;

	bool mapaContemVar(atributos variavel){
		
		bool result = false;
		int i;

		for(i = 0; i < mapaVariaveis.size(); i++){
			if(mapaVariaveis[i].nome_var == variavel.nome_var){
				result = true;
				break;
			}
		}

		return result;
	}

	bool mapaAddVar(atributos variavel){
		if(!mapaContemVar(variavel)){
			mapaVariaveis.push_back(variavel);
			return true;
		} else{
			return false;
		}
	}

	void mapaPushVar(atributos variavel){
		mapaVariaveis.push_back(variavel);
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
%token TK_TIPO_INT TK_TIPO_FLOAT TK_TIPO_CHAR TK_TIPO_BOOL
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

E 			: '(' E ')'
			{
				$$.traducao = $2.traducao;
			}
			| E '+' E
			{

			}
			| TK_ID

			| TIPO
			{
				$$ = $1;
			}
			;
TIPO 		: TK_TIPO_INT
			{
				mapaContemVar($1);
				$$.label = create_var_names();
				$$.t_var = "int";
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + $1.label + ";\n";
				insert_variable($$.t_var, $1.label, $1.traducao);


				$$.label = proximo("num");
				$$.tipo = "int";
				$$.val=$$.traducao;
				variaveis var = popular("", $$.tipo, $$.label);
				variables_to_declare.push_back(var);
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
			}


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
