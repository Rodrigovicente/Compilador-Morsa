%{
#include <iostream>
#include <string>
#include <sstream>

#define YYSTYPE atributos

using namespace std;

int yylex(void);
void yyerror(string);

typedef struct attr
{
	string label;
	string traducao;
	string tipo_var;
	string nome_var;
	int tamanho; // Adicionado para utilizar em string!
} atributos;

typedef struct mapaVar
{
	vector<atributos> attrs;
	bool isLoop;
	string rotulo_inicio;
	string rotulo_fim;
} mapaVariaveis;

static int count_vars = 0;
static int count_tmps = 0;
static int count_rots = 0;

vector<mapaVariaveis> pilhaMapas;


/* !!!!!!!!!!!!! TEM QUE REFAZER TODAS AS FUNÇÕES DO MAPA PARA CONSIDERAR A PILHA DE MAPAS !!!!!!!!!!!! */

int[] mapasContemVar(atributos variavel){
	int result[2];
 	result[0] = -1;
	result[1] = -1;
	int i, j;

	for(i = pilhaMapas.size() - 1; i >= 0; i--){
		for(j = 0; j < pilhaMapas[i].attrs.size(); j++){
			if(pilhaMapas[i].attrs[j].nome_var == variavel.nome_var){
				result[0] = i;
				result[1] = j;
				break;
			}
		}
	}

	return result;
}

atributos mapaGetVar(atributos variavel){

	atributos saida;

	int i, j;

	for(i = pilhaMapas.size() - 1; i >= 0; i--){
		for(j = 0; j < pilhaMapas[i].attrs.size(); j++){
			if(pilhaMapas[i].attrs[j].nome_var == variavel.nome_var){
				saida = pilhaMapas[i].attrs[j].nome_var;
				saida.traducao = "";
				return saida;
			}
		}
	}

	saida.label = "!morsa"
	return saida;

}

bool mapasAddVar(atributos variavel){
	if(mapaContemVar(variavel)[0] != -1){
		pilhaMapas[i].push_back(variavel);
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

	string nome = "var_"+convert.str();
	return nome;
}

string cria_nome_tmp(){
	ostringstream convert;
	convert << count_tmps;

	string nome = "tmp_"+convert.str();
	return nome;
}

string cria_nome_rot(){
	ostringstream convert;
	convert << count_tmps;

	string nome = "rot_"+convert.str();
	return nome;
}



%}

%token TK_NUM TK_REAL TK_CHAR TK_BOOL TK_ID
%token TK_TIPO_INT TK_TIPO_FLOAT TK_TIPO_CHAR TK_TIPO_BOOL
%token TK_MAIN TK_ID TK_TIPO_INT
%token TK_FIM TK_ERROR

%start S

%left '+'

%%

S 			: INIT_BLOCO BLOCO END_BLOCO
			{
				cout << "/*Compilador MORSA*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << $5.traducao << "\treturn 0;\n}" << endl;
			}
			;

INIT_BLOCO	: {
				mapaVariaveis mapVar;
				pilhaMapas.push_back(mapVar);
			}
			;
END_BLOCO	: {
				pilhaMapas.pop_back();
			}

BLOCO		: '{' COMANDOS '}'
			{
				$$.traducao = $2.traducao;
			}
			;

COMANDOS	: COMANDO COMANDOS
			{
				$$.traducao = $1.traducao + $2.traducao;
			}
			| INIT_BLOCO BLOCO END_BLOCO COMANDOS
			{

			}
			;

COMANDO 	: E ';'
			| DECLARACAO ';'
			| ATTR ';'
			| BL_CONDICIONAL ';'
			| BL_LOOP ';'
			;

BL_CONDICIONAL : TK_COM_IF '(' CONDICAO ')' INIT_BLOCO BLOCO END_BLOCO // IF
			{

			}
			| TK_COM_IF '(' CONDICAO ')' INIT_BLOCO BLOCO END_BLOCO TK_COM_ELSE INIT_BLOCO BLOCO END_BLOCO // IF ELSE
			{

			}
			| TK_COM_IF '(' CONDICAO ')' INIT_BLOCO BLOCO END_BLOCO TK_COM_ELSE BL_CONDICIONAL_ELSEIF // IF ELSE IF
			{

			}
			| TK_COM_SWITCH '(' TK_ID ')' '{' BL_CONDICIONAL_SWITCH TK_COM_DEFAULT ':' INIT_BLOCO END_BLOCO // SWITCH (INCOMPLETO, TEM QUE ENTENDER COMO FUNCIONA)
			;

BL_CONDICIONAL_ELSEIF : TK_COM_IF '(' CONDICAO ')' INIT_BLOCO BLOCO END_BLOCO TK_COM_ELSE BL_CONDICIONAL_ELSEIF
			{

			}
			| TK_COM_IF '(' CONDICAO ')' INIT_BLOCO BLOCO END_BLOCO
			{

			}
			| TK_COM_IF '(' CONDICAO ')' INIT_BLOCO BLOCO END_BLOCO TK_COM_ELSE INIT_BLOCO BLOCO END_BLOCO
			{

			}
			;

BL_LOOP		: INIT_BLOCO TK_COM_WHILE '(' CONDICAO ')' BLOCO END_BLOCO // WHILE
			{

			}
			| INIT_BLOCO TK_COM_FOR '(' ATTR ';' CONDICAO ';' ATTR ')' BLOCO END_BLOCO // FOR
			{

			}
			| INIT_BLOCO TK_COM_DO BLOCO TK_COM_WHILE '(' CONDICAO ')' END_BLOCO // DO... WHILE

E 			: '(' E ')'
			{
				$$.traducao = $2.traducao;
			}
			| TK_CAST E
			{
				// Casting
			}
			| E TK_OP_ARI E
			{
				// + - * /
			}
			| E TK_OP_LOG E
			{
				// && || !
			}
			| CONDICAO
			| TK_ID
			{
				$$ = mapaGetVar($1);
				if($$.label == "!morsa"){
					yyerror("E Esta variavel morsa esta em extincao");
				}

			}
			| TK_NUM
			{
				$$ = $1;
				$$.label = cria_nome_var();
				$$.traducao =  + $1.tipo + " " + $$.label + ";\n" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_REAL
			| TK_CHAR
			{
				$$ = $1;
				$$.label = cria_nome_var();
				$$.traducao =  $1.tipo + " " + $$.label + ";\n" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_BOOL
			{
				$$ = $1;
				$$.label = cria_nome_var();
				$$.traducao = $1.tipo + " " + $$.label + ";\n" + $$.label + " = " + $1.label + ";\n";
			}
			;

CONDICAO 	: E TK_OP_REL E 	//OPERAÇÕES RELACIONAIS
			{
				// > >= < <= == !=
			}

ATTR 		: TK_ID TK_ATTR E       	//TK_ATTR -> = *= /= += == ++ --
			{
				//TK_ATTR é o token de atribuicao, neste caso o yylval.label pode ser = += -= *= /=
				$$ = mapaGetVar($1);

				if($$.label == "!morsa"){
					yyerror("ERRO: Não existe uma variável com este nome.");
				} else{
					if($2.label == "="){
						$$.traducao = $3.traducao;
						$$.traducao += $$.label + " = " + $3.label + "; \n";

					} else if($2.label == "*=" || $2.label == "/=" || $2.label == "+=" || $2.label == "-="){
						if(($1.tipo_var == "int" || $1.tipo_var == "float") && ($3.tipo_var == "int" || $3.tipo_var == "float")){
								$$.traducao = $3.traducao;
								$$.traducao += $$.label + " " + $2.label + " " + $3.label + "; \n";
						} else {
							yyerror("ERRO: Os tipos das variáveis ou expressões não são válidos para a operação (ao menos uma não é float ou int).");
						}

					}
				}

			}
			| TK_ID TK_ATTR
			{
				//TK_ATTR, neste caso, neste caso o yylval.label pode ser ++ --
				$$ = mapaGetVar($1);

				if($$.label == "!morsa"){
					yyerror("ERRO: Não existe uma variável com este nome.");
				} else{
					if($2.label == "++"){
						if($$.tipo_var == "int" || $$.tipo_var == "float"){
							$$.traducao = $$.label + " = " + $$.label + " + 1; \n";
						} else{
							yyerror("ERRO: A variável não é do tipo numérico (int ou float)");
						}

					} else if($2.label == "--"){
						if($$.tipo_var == "int" || $$.tipo_var == "float"){
							$$.traducao = $$.label + " = " + $$.label + " - 1; \n";
						} else{
							yyerror("ERRO: A variável não é do tipo numérico (int ou float)");
						}

					} else{
						yyerror("ERRO: Operação de atribuição não está completa (está faltando uma variável ou expressão para ser atribuida à variável especificada).");
					}
				}
			}

DECLARACAO	: TK_TIPO TK_ID
			{
				$$ = mapaGetVar($2);

				if($$.label == "!morsa"){
					$$.tipo_var = $1.label;
					$$.nome_var = $2.label;
					$$.label = cria_nome_var();
					$$.traducao = $$.tipo + " " + $$.label + "; \n";
					mapasAddVar($$);
				} else{
					yyerror("ERRO: Já existe uma variável com este nome.");
				}
			}
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
