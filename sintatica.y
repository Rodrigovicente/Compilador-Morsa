%{
#include <iostream>
#include <string>
#include <sstream>
#include <vector>
#include <map>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define YYSTYPE atributos

using namespace std;

int yylex(void);
void yyerror(string);

struct attr
{
	string label;
	string traducao;
	string tipo_var;
	string nome_var;
	string str_tamanho;
	string start_block_lb;
	string end_block_lb;
};
typedef struct attr atributos;

struct mapaVar
{
	vector<atributos> attrs;
	bool isLoop;
	string start_block_lb;
	string end_block_lb;
	bool isQuebravel;
};

typedef struct mapaVar mapaVariaveis;

struct declaracao_Var
{
	string tipo_var;
	string nome_var;
	bool isFreeable;
};
typedef struct declaracao_Var declaracaoVar;

static int count_vars = 0;
static int count_tmps = 0;
static int count_rots = 0;

vector<mapaVariaveis> pilhaMapas;
vector<declaracaoVar> pilhaDeclaracao;
vector<atributos> pilhaSwitch;

vector<string> seqIndex;

bool isComentario = false;


// relação tipo em morsa - tipo em c
map<string,string> relacaoTipos = 	{
										{"int","int"},
										{"float","float"},
										{"char","char"},
										{"bool","int"},
										{"string","char*"},
										{"!morsa","!morsa"}
									};

string traducao_tipo(atributos attr){
	string result;

	result = relacaoTipos.find(attr.tipo_var)->second;

	return result;
}

bool isConvertivel(atributos attr1, atributos attr2){

	// OTIMIZAR

	if(attr1.tipo_var == "int" && attr2.tipo_var == "float"){
		return true;
	} else if(attr1.tipo_var == "int" && attr2.tipo_var == "char"){
		return true;
	} else if(attr1.tipo_var == "float" && attr2.tipo_var == "int"){
		return true;
	} else if(attr1.tipo_var == "float" && attr2.tipo_var == "char"){
		return true;
	} else if(attr1.tipo_var == "char" && attr2.tipo_var == "int"){
		return true;
	} else if(attr1.tipo_var == "char" && attr2.tipo_var == "float"){
		return true;
	} else if(attr1.tipo_var == attr2.tipo_var){
		return true;
	} else{
		return false;
	}

}

bool mapasContemVar(atributos variavel){
	
	bool result = false;
	int i, j;
	
	if(!pilhaMapas.empty()){
		for(i = pilhaMapas.size() - 1; i >= 0; i--){
			if(!pilhaMapas[i].attrs.empty()){
				for(j = 0; j < pilhaMapas[i].attrs.size(); j++){
					if(pilhaMapas[i].attrs[j].nome_var == variavel.nome_var){
						result = true;
						break;
					}
				}
			}
		}
	}
	return result;
}

void declaracaoAddVar(string tipo_var, string nome_var){
				//printf("declaracao add var\n");
	if(!isComentario){
		declaracaoVar variavel;
		variavel.tipo_var = tipo_var;
		variavel.nome_var = nome_var;
		variavel.isFreeable = true;
		
		pilhaDeclaracao.push_back(variavel);

		printf("ADICIONEI PARA DECLARAR: %s - total: %d\n", pilhaDeclaracao[pilhaDeclaracao.size()-1].nome_var.c_str(), pilhaDeclaracao.size());
	}
}

void declaracaoAddVar(string tipo_var, string nome_var, bool isFreeable){
	if(!isComentario){
		declaracaoVar variavel;
		variavel.tipo_var = tipo_var;
		variavel.nome_var = nome_var;
		variavel.isFreeable = isFreeable;
		
		pilhaDeclaracao.push_back(variavel);

		printf("ADICIONEI PARA DECLARAR: %s - total: %d\n", pilhaDeclaracao[pilhaDeclaracao.size()-1].nome_var.c_str(), pilhaDeclaracao.size());

	}
}

string declaraVariaveis(){
	string result = "// declaracao de todas as variáveis\n";
	int i;

	for(i = 0; i < pilhaDeclaracao.size(); i++){
		if(pilhaDeclaracao[i].tipo_var != "!morsa"){
			result += pilhaDeclaracao[i].tipo_var + " " + pilhaDeclaracao[i].nome_var + "; \n";
		}
	}

	return result;
}

string freeVariaveis(){
	string result = "// free de todas as variáveis\n";
	int i;

	for(i = 0; i < pilhaDeclaracao.size(); i++){
		if((pilhaDeclaracao[i].tipo_var.find("*") != string::npos) && (pilhaDeclaracao[i].isFreeable == true)){ //tipo_var contains "*"
			result += "free(" + pilhaDeclaracao[i].nome_var + "); \n";
		}
	}

	return result;
}

bool mapasAddVar(atributos variavel){
	if(!isComentario){
		bool aux;
		aux = mapasContemVar(variavel);
		if(!aux){
			pilhaMapas[pilhaMapas.size()-1].attrs.push_back(variavel);
			printf("ADICIONEI NO MAPA: %d\n",pilhaMapas[pilhaMapas.size()-1].attrs.size() );

			return true;
		} else{
			printf("NAO ADICIONEI NO MAPA\n" );
			return false;
		}
	}
	return false;
}

atributos mapaGetVar(atributos variavel){

	atributos saida;

	int i, j;

	for(i = pilhaMapas.size() - 1; i >= 0; i--){
		if(!pilhaMapas[i].attrs.empty()){
			for(j = 0; j < pilhaMapas[i].attrs.size(); j++){
				if(pilhaMapas[i].attrs[j].nome_var == variavel.label){
					saida = pilhaMapas[i].attrs[j];
					//saida.nome_var = pilhaMapas[i].attrs[j].nome_var;
					//saida.traducao = "";
					printf("ACHEI A VARIAVEL NOS MAPAS: %s - %s\n", saida.label.c_str() , saida.str_tamanho.c_str() );
					return saida;
				}
			}
		}
	}
	printf("*NAO* ACHEI A VARIAVEL NOS MAPAS: %s\n", variavel.label.c_str());
	saida.label = "!morsa";
	return saida;

}

bool mapaSetTam(string nome_var, string str_tamanho){

	if(!isComentario){
		bool saida;

		int i, j;
		printf(" *********** mudando tamanho string\n" );

		for(i = pilhaMapas.size() - 1; i >= 0; i--){
			if(!pilhaMapas[i].attrs.empty()){
				for(j = 0; j < pilhaMapas[i].attrs.size(); j++){
					if(pilhaMapas[i].attrs[j].nome_var == nome_var){
						pilhaMapas[i].attrs[j].str_tamanho = str_tamanho;
						printf(" --- tamanho novo: %s\n", pilhaMapas[i].attrs[j].str_tamanho.c_str() );
						saida = true;
						return saida;
					}
				}
			}
		}

		printf(" .... nao mudou .....: %s\n", str_tamanho.c_str() );
		saida = false;
		return saida;
	}
	return false;
}
bool mapaSetTipo(string nome_var, string tipo_var){

	if(!isComentario){
		bool saida;

		int i, j, k;
		printf(" *********** mudando tipo var\n" );

		for(i = pilhaMapas.size() - 1; i >= 0; i--){
			if(!pilhaMapas[i].attrs.empty()){
				for(j = 0; j < pilhaMapas[i].attrs.size(); j++){
					if(pilhaMapas[i].attrs[j].nome_var == nome_var){
						pilhaMapas[i].attrs[j].tipo_var = tipo_var;

						for(k = 0; i < pilhaDeclaracao.size(); i++){
							if(pilhaDeclaracao[k].nome_var == nome_var){
								pilhaDeclaracao[k].tipo_var = tipo_var;
								printf("mudou o tipo\n");
								break;
							}
						}
								printf("mudou o tipo 2\n");
						saida = true;
						return saida;
					}
				}
			}
		}
		saida = false;
		return saida;
	}
	return false;
}

string breakMapas(){
	printf("DANDO BREAK\n");
	string result = "!morsa";
	int i, j;
	int mapaTam = pilhaMapas.size();

	for(i = (mapaTam-1); i >= 0; i--){
		if(pilhaMapas[i].isQuebravel){
			result = pilhaMapas[i].end_block_lb;
			break;
		}
	}

	return result;
}

string continueMapas(){
	printf("DANDO CONTINUE\n");
	string result = "!morsa";
	int i, j;
	int mapaTam = pilhaMapas.size();

	for(i = (mapaTam-1); i >= 0; i--){
		if(pilhaMapas[i].isQuebravel){
			result = pilhaMapas[i].start_block_lb;
			break;
		}
	}

	return result;
}

string cria_nome_var(){
	ostringstream convert;
	convert << count_vars;
	count_vars++;
	string nome = "var_"+convert.str();
	return nome;
}

string cria_nome_tmp(){
	ostringstream convert;
	convert << count_tmps;
	count_tmps++;
	string nome = "tmp_"+convert.str();
	return nome;
}

string cria_nome_rot(){
	ostringstream convert;
	convert << count_rots;
	count_rots++;
	string nome = "rot_"+convert.str();
	return nome;
}  
  

%}

/*%token TK_NUM TK_REAL TK_CHAR TK_BOOL TK_ID
%token TK_TIPO_INT TK_TIPO_FLOAT TK_TIPO_CHAR TK_TIPO_BOOL
%token TK_MAIN TK_ID TK_TIPO_INT
%token TK_FIM TK_ERROR
%token BL_CONDICIONAL BL_CONDICIONAL_SWITCH BL_CONDICIONAL_SWITCH
%token TK_COM_IF TK_COM_ELSE TK_COM_SWITCH
%token TK_COM_WHILE TK_COM_FOR TK_COM_DO TK_CAST TK_OP_ARI TK_OP_LOG TK_STRING TK_OP_REL TK_ATTR TK_TIPO TK_TIPO_INFERIDO*/

%token TK_OP_ARI_AS TK_OP_ARI_MD TK_OP_REL TK_OP_LOG
%token TK_CAST TK_ATTR TK_BOOL TK_ID TK_NUM TK_CHAR TK_STRING TK_REAL
%token TK_TIPO TK_TIPO_INFERIDO
%token TK_COM_IF TK_COM_ELSE TK_COM_WHILE TK_COM_FOR TK_COM_DO TK_COM_SWITCH TK_COM_BREAK TK_COM_CONTINUE TK_CASE TK_DEFAULT
%token TK_PRINT TK_PRINTLN TK_SCAN
%token TK_ENDL TK_BRKLN TK_SEMICOL TK_COLON TK_COMMA
%token TK_ABRECOLCH TK_FECHACOLCH TK_ABRECHAV TK_FECHACHAV
%token TK_START_COMMENT TK_END_COMMENT TK_LN_COMMENT



%start S


%right TK_ATTR
%left TK_OP_LOG
%left TK_OP_REL
%left TK_OP_ARI_AS
%left TK_OP_ARI_MD


%%

S 			: INIT_BLOCO MAIN_BLOCO END_BLOCO
			{
				string out = "/*Compilador MORSA*/ \n #include <iostream>\n#include <string.h>\n#include<string.h>\n#include<stdio.h>\nusing namespace std;\nint main(void)\n{\n" + declaraVariaveis() + "\n\n" + $2.traducao + "\n\n" + freeVariaveis() + "\n \t return 0;\n}\n";
				FILE* fout = fopen("intermed.cpp", "w");
				  fprintf(fout, "%s", out.c_str());
				cout << out;
			}
			;

INIT_BLOCO	:
			{
				mapaVariaveis mapVar;
				mapVar.start_block_lb = cria_nome_rot();
				mapVar.end_block_lb = cria_nome_rot();
				mapVar.isQuebravel = false;
				pilhaMapas.push_back(mapVar);

				$$.start_block_lb = mapVar.start_block_lb;
				$$.end_block_lb = mapVar.end_block_lb;

				printf("+++CRIEI UM MAPA com rotulo: %s\n", pilhaMapas[pilhaMapas.size()-1].start_block_lb.c_str() );
			}
			;

INIT_BLOCO_BREAK :
			{
				mapaVariaveis mapVar;
				mapVar.start_block_lb = cria_nome_rot();
				mapVar.end_block_lb = cria_nome_rot();
				mapVar.isQuebravel = true;
				pilhaMapas.push_back(mapVar);

				$$.start_block_lb = mapVar.start_block_lb;
				$$.end_block_lb = mapVar.end_block_lb;

				printf("+++CRIEI UM MAPA QUEBRAVEL com rotulo: %s\n", pilhaMapas[pilhaMapas.size()-1].start_block_lb.c_str() );
			}
			;

END_BLOCO	:
			{
				printf("---TIREI UM MAPA com rotulo: %s\n", pilhaMapas[pilhaMapas.size()-1].start_block_lb.c_str() );
				pilhaMapas.pop_back();
			}

MAIN_BLOCO	: BRKLN COMANDOS BRKLN
			{
				$$.traducao = $2.traducao;
				printf("CRIEI O BLOCO PRINCIPAL: %d\n", pilhaMapas.size());
			}
			;

BLOCO		: TK_ABRECHAV BRKLN COMANDOS BRKLN TK_FECHACHAV
			{
				$$.traducao = $3.traducao;
				printf("CRIEI UM BLOCO COM NIVEL: %d\n", pilhaMapas.size());
			}
			;

COMANDOS	: COMANDO COMANDOS
			{
				$$.traducao = $1.traducao  + $2.traducao;
			}
			| INIT_BLOCO BLOCO END_BLOCO COMANDOS
			{
				$$.traducao = $2.traducao  + $4.traducao;

			}
			|
			;

COMANDO 	: E END_COMANDO
			| DECLARACAO END_COMANDO
			| ATTR END_COMANDO
			| PRINT END_COMANDO
			| PRINTLN END_COMANDO
			| SCAN END_COMANDO
			| BREAK END_COMANDO
			| CONTINUE END_COMANDO
			| BL_CONDICIONAL BRKLN
			| BL_SWITCH BRKLN
			| BL_LOOP BRKLN
			| COMENT BRKLN
			| COMENT_LN BRKLN
			;

END_COMANDO	: TK_BRKLN BRKLN
			{
				$$ = $1;
				printf("break com \\n\n");
			}
			| TK_SEMICOL BRKLN
			{
				$$ = $1;
				printf("break com ;\n");
			}
			;

BRKLN 		: TK_BRKLN BRKLN
			{
				$$ = $1;
				printf("break lineeeee\n");
			}
			| TK_BRKLN
			{
				$$ = $1;
				printf("break line\n");
			}
			|
			;

COMENT		: TK_START_COMMENT START_COMENT BRKLN COMANDOS BRKLN END_COMENT TK_END_COMMENT
			{
				printf("COMENTARIO DE N LINHAS\n");
				$$.traducao = "/* comentario */ \n";

			}

COMENT_LN 	: TK_LN_COMMENT START_COMENT COMANDO END_COMENT
			{
				printf("COMENTARIO DE UMA LINHA\n");
				$$.traducao = "// comentario \n";

			}

START_COMENT:
			{
				isComentario = true;
			}
			;

END_COMENT 	:
			{
				isComentario = false;
			}

CONDICAO 	: E
			{
				printf("CONFERINDO CONDICAO\n");
				if($1.tipo_var == "bool"){
					$$ = $1;
				} else {
					yyerror("ERRO: A condição do comando deve retornar tipo bool.");
				}
			}
			;

BL_CONDICIONAL : TK_COM_IF '(' CONDICAO ')' INIT_BLOCO BLOCO END_BLOCO	// IF
			{
				string ini_label = $5.start_block_lb;
				string end_label = $5.end_block_lb;
				
				$$.end_block_lb = end_label;

				$$.traducao =  $3.traducao;
				$$.traducao += $1.label + "(" + $3.label + ") goto " + ini_label + ";\n" + "goto " + end_label + ";\n";
				$$.traducao += "\n" + ini_label + ": \n" + $6.traducao + "\n" + end_label + ": \n";
				
			}
			| TK_COM_IF '(' CONDICAO ')' INIT_BLOCO BLOCO END_BLOCO TK_COM_ELSE INIT_BLOCO BLOCO END_BLOCO 	//IF ELSE
			{

				string ini_label_else = $9.start_block_lb;
				string end_label_else = $9.end_block_lb;
				
				$$.end_block_lb = end_label_else;

				string ini_label_if = $5.start_block_lb;
				string end_label_if = $5.end_block_lb;

				$$.traducao = $3.traducao;
				$$.traducao += $1.label + "(" + $3.label + ") goto " + ini_label_if + ";\n" + "goto " + ini_label_else + ";\n";
				$$.traducao += "\n" + ini_label_if + ": \n" + $6.traducao + "goto " + end_label_else + "; \n\n" + ini_label_else + ": \n" + $10.traducao + "\n" + end_label_else + ": \n";
			}
			| TK_COM_IF '(' CONDICAO ')' INIT_BLOCO BLOCO END_BLOCO TK_COM_ELSE BL_CONDICIONAL		// IF ELSE IF
			{
				$$.end_block_lb = $9.end_block_lb;
				
				string ini_label = $5.start_block_lb;
				string end_label = $5.end_block_lb;
				string end_label_elseif = $$.end_block_lb;
  
				$$.traducao =  $3.traducao;
				$$.traducao += $1.label + "(" + $3.label + ") goto " + ini_label + ";\n" + "goto " + end_label + ";\n";
				$$.traducao += "\n" + ini_label + ": \n" + $6.traducao + "goto " + end_label_elseif + "; \n\n" + end_label + ": \n";
  
				$$.traducao += $9.traducao;

			}
			;

BL_SWITCH 	: TK_COM_SWITCH INIT_BLOCO_BREAK '(' SWITCH_E ')' '{' BRKLN CASE BRKLN '}' END_BLOCO BRKLN
			{
				string aux_var1 = $2.start_block_lb;
				string aux_var2 = $2.end_block_lb;

				//$$.traducao = $4.traducao;
				$$.traducao = "\n" + aux_var1 + ": \n" + $8.traducao + "\n\n" + aux_var2 + ": \n";
				pilhaSwitch.pop_back();
			}
			;

SWITCH_E	: E
			{
				$$ = $1;
				pilhaSwitch.push_back($$);
				printf("CHEGOU AQUI 0\n");
			}
			;

CASE 		: TK_CASE E COMANDOS CASE
			{
				printf("CHEGOU AQUI 1\n");
				$$.start_block_lb = cria_nome_rot();
				$$.end_block_lb = cria_nome_rot();

				atributos aux_var = pilhaSwitch[pilhaSwitch.size()-1];

				$$.traducao = $2.traducao;
				if($2.tipo_var == aux_var.tipo_var){
					$$.traducao += "if( " + $2.label + " == " + aux_var.label + " ) goto " + $$.start_block_lb + "; \ngoto " + $$.end_block_lb + "; \n";
				} else{
					$$.traducao += "goto " + $$.end_block_lb + "; \n";
				}
				$$.traducao += "\n" + $$.start_block_lb + ": \n" + $3.traducao + "goto " + $4.start_block_lb + ";\n\n" + $$.end_block_lb + ": \n" + $4.traducao;
			
			}
			| TK_CASE E COMANDOS
			{
				printf("CHEGOU AQUI 2\n");
				$$.start_block_lb = cria_nome_rot();
				$$.end_block_lb = cria_nome_rot();

				atributos aux_var = pilhaSwitch[pilhaSwitch.size()-1];

				$$.traducao = $2.traducao;
				if($2.tipo_var == aux_var.tipo_var){
					$$.traducao += "if( " + $2.label + " == " + aux_var.label + " ) goto " + $$.start_block_lb + "; \ngoto " + $$.end_block_lb + "; \n";
				} else{
					$$.traducao += "goto " + $$.end_block_lb + "; \n";
				}
				$$.traducao += "\n" + $$.start_block_lb + ": \n" + $3.traducao + "\n" + $$.end_block_lb + ": \n";

			}
			| TK_DEFAULT COMANDOS
			{
				printf("CHEGOU AQUI 3\n");
				$$.start_block_lb = cria_nome_rot();

				$$.traducao = $2.traducao + "\n" + $$.start_block_lb + ": \n";

			}
			|
			;

BREAK 		: TK_COM_BREAK
			{
				string aux_var = breakMapas();
				$$.traducao = "goto " + aux_var + "; \n";
			}
			;

CONTINUE	: TK_COM_CONTINUE
			{
				string aux_var = continueMapas();
				$$.traducao = "goto " + aux_var + "; \n";
			}
			;

BL_LOOP		: INIT_BLOCO_BREAK TK_COM_WHILE '(' CONDICAO ')' BLOCO END_BLOCO
			{
				string ini_label = $1.start_block_lb;
				string end_label = $1.end_block_lb;

				string aux_var = cria_nome_rot();

				$$.traducao += "\n" + ini_label + ": \n";
				$$.traducao += $4.traducao + "if( " + $4.label + " ) goto " + aux_var + "; \ngoto " + end_label + "; \n";
				$$.traducao += "\n" + aux_var + ": \n" + $6.traducao + "goto " + ini_label + "; \n\n" + end_label + ": \n";


				/*
					int i = 0;
					while(i < 10){
						i++;
					}
					//----------------------------

					int tmp_0;
					int var_0;
					int tmp_1;
					int tmp_3;
					

					tmp_0 = 0;
					var_0 = tmp_0;

					
					rot_1:
					tmp_1 = 10;
					tmp_2 = var_0;
					tmp_3 = tmp_1 < tmp_2;
					
					if(tmp_3) goto rot_2;
					goto rot_3;
					
					rot_2:
						//....
					goto rot_1;
					
					rot_3:	
				*/

			}
			| INIT_BLOCO_BREAK TK_COM_FOR '(' ATTR TK_SEMICOL CONDICAO TK_SEMICOL ATTR ')' BLOCO END_BLOCO
			{
				// FOR

				string ini_label = $1.start_block_lb;
				string end_label = $1.end_block_lb;

				string aux_var1 = cria_nome_rot();
				string aux_var2 = cria_nome_rot();

				$$.traducao = $4.traducao + "\n" + aux_var1 + ": \n" + $6.traducao;
				$$.traducao += "if( " + $6.label + " ) goto " + aux_var2 + "; \ngoto " + end_label + "; \n";
				$$.traducao += "\n" + aux_var2 + ": \n" + $10.traducao + "\n" + ini_label + ": \n" + $8.traducao + "goto " + aux_var1 + "; \n\n" + end_label + ": \n";


				/*
					for(int i = 0; i < 10; i++){
						// ...
					}


					int var_0;
					int tmp_0;
					int tmp_1;

					rot_0:
					var_0 = 0;
					tmp_0 = 10;
					tmp_1 = var_0 < tmp_0;

					if(tmp_1) goto rot_1;
					goto rot_2;

					rot_1:
					//...
					
					var_0 = var_0 + 1;
					goto rot_0;

					rot_2:




				*/
			}
			| INIT_BLOCO_BREAK TK_COM_DO BLOCO TK_COM_WHILE '(' CONDICAO ')' END_BLOCO
			{
				// DO... WHILE

				string ini_label = $1.start_block_lb;
				string end_label = $1.end_block_lb;
				$$.traducao = "\n" + ini_label + ":\n" + $3.traducao + $6.traducao;
				$$.traducao += "if( " + $6.label + " ) " + "goto " + ini_label + "; \n\n";
			}
			;

E 			: '(' E ')'
			{
				$$ = $2;
			}
			| TK_CAST E
			{
				$$.label = cria_nome_var();
				$$.traducao = $2.traducao;

				if($1.label == "(int)"){
					$$.tipo_var = "int";
					if($2.tipo_var == "float"){
						string aux_var = cria_nome_tmp();

						declaracaoAddVar(traducao_tipo($$), $$.label);
						declaracaoAddVar(traducao_tipo($$), aux_var);

						$$.traducao += aux_var + " = (int) " + $2.label + "; \n";
						$$.traducao += $$.label + " = " + aux_var + "; \n";

					} else if($2.tipo_var == "int"){
						declaracaoAddVar(traducao_tipo($$), $$.label);
						$$.traducao += $$.label + " = " + $2.label + "; \n";

					} else if($2.tipo_var == "char"){
						string aux_var = cria_nome_tmp();

						declaracaoAddVar(traducao_tipo($$), $$.label);
						declaracaoAddVar(traducao_tipo($$), aux_var);
						$$.traducao += aux_var + " = (int) " + $2.label + "; \n";
						$$.traducao += $$.label + " = " + aux_var + "; \n";

					} else{
						yyerror("ERROR: Não é possível realizar a conversão para este tipo.");
					}

				} else if($1.label == "(float)"){
					$$.tipo_var = "float";
					if($2.tipo_var == "int"){
						string aux_var = cria_nome_tmp();

						declaracaoAddVar(traducao_tipo($$), aux_var);
						declaracaoAddVar(traducao_tipo($$), $$.label);
						$$.traducao += aux_var + " = (float) " + $2.label + "; \n";
						$$.traducao += $$.label + " = " + aux_var + "; \n";

					} else if($2.tipo_var == "float"){
						declaracaoAddVar(traducao_tipo($$), $$.label);
						$$.traducao += $$.label + " = " + $2.label + "; \n";
					} else if($2.tipo_var == "char"){
						string aux_var = cria_nome_tmp();

						declaracaoAddVar(traducao_tipo($$), aux_var);
						declaracaoAddVar(traducao_tipo($$), $$.label);
						$$.traducao += aux_var + " = (float) " + $2.label + "; \n";
						$$.traducao += $$.label + " = " + aux_var + "; \n";
					} else{
						yyerror("ERROR: Não é possível realizar a conversão para este tipo.");
					}
				} else{ // caso cast (char)
					$$.tipo_var = "char";
					if($2.tipo_var == "int" ){
						string aux_var = cria_nome_tmp();

						declaracaoAddVar(traducao_tipo($$), aux_var);
						declaracaoAddVar(traducao_tipo($$), $$.label);
						$$.traducao += aux_var + " = (char) " + $2.label + "; \n";
						$$.traducao += $$.label + " = " + aux_var + "; \n";
					} else if($2.tipo_var == "float"){
						string aux_var1 = cria_nome_tmp();
						string aux_var2 = cria_nome_tmp();

						declaracaoAddVar("int", aux_var1);
						declaracaoAddVar(traducao_tipo($$), aux_var2);
						declaracaoAddVar(traducao_tipo($$), $$.label);
						$$.traducao += aux_var1 + " = (int) " + $2.label + "; \n";
						$$.traducao += aux_var2 + " = (char) " + aux_var1 + "; \n";
						$$.traducao += $$.label + " = " + aux_var2 + "; \n";

					} else{
						yyerror("ERROR: Não é possível realizar a conversão para este tipo.");
					}
				}

			}
			| E TK_OP_ARI_AS E
			{
				// + - * /
				$$.label = cria_nome_tmp();
				$$.traducao = $1.traducao + $3.traducao;

				// para numeros
				if(($1.tipo_var == "int" || $1.tipo_var == "float") && ($3.tipo_var == "int" || $3.tipo_var == "float")){
					if($1.tipo_var == $3.tipo_var){
						$$.tipo_var = $1.tipo_var;

						declaracaoAddVar(traducao_tipo($$), $$.label);
						$$.traducao += $$.label + " = " + $1.label + " " + $2.label + " " + $3.label + "; \n";
					} else{
						$$.tipo_var = "float";
						if($1.tipo_var == "float"){
							string aux_var = cria_nome_tmp();

							declaracaoAddVar(traducao_tipo($$), aux_var);
							declaracaoAddVar(traducao_tipo($$), $$.label);
							$$.traducao += aux_var + " = (float) " + $3.label + "; \n";
							$$.traducao += $$.label + " = " + $1.label + " " + $2.label + " " + aux_var + "; \n";
						} else{
							string aux_var = cria_nome_tmp();

							declaracaoAddVar(traducao_tipo($$), aux_var);
							declaracaoAddVar(traducao_tipo($$), $$.label);
							$$.traducao += aux_var + " = (float) " + $1.label + "; \n";
							$$.traducao += $$.label + " = " + aux_var + " " + $2.label + " " + $3.label + "; \n";
						}
					}
				}
				// para char e string (concatenacao)
				else {
					if($2.label == "+"){
						$$.tipo_var = "string";

						if($1.tipo_var == "char" && $3.tipo_var == "char"){
							yyerror("ERRO: Não é possivel concatenar expressões tipo char.");
							// CONTINUAR ?
						
						} else if($1.tipo_var == "char" && $3.tipo_var == "string"){
							yyerror("ERRO: Não é possivel concatenar expressões tipo string com expressões tipo char.");
							// CONTINUAR ?

						} else if($1.tipo_var == "string" && $3.tipo_var == "char"){
							yyerror("ERRO: Não é possivel concatenar expressões tipo string com expressões tipo char.");
							// CONTINUAR ?

						}else if($1.tipo_var == "string" && $3.tipo_var == "string"){
							$$.str_tamanho = to_string(stoi($1.str_tamanho) + stoi($3.str_tamanho));
							
							string aux_var1 = cria_nome_tmp();
							string aux_var2 = cria_nome_tmp();
							string aux_var3 = cria_nome_tmp();
							string aux_var4 = cria_nome_tmp();
							string aux_var5 = cria_nome_tmp();


							declaracaoAddVar("int", aux_var1);
							declaracaoAddVar("int", aux_var2);
							declaracaoAddVar("int", aux_var3);
							declaracaoAddVar(traducao_tipo($$), aux_var4);
							declaracaoAddVar(traducao_tipo($$), aux_var5, false);
							declaracaoAddVar(traducao_tipo($$), $$.label);

							$$.traducao += aux_var1 + " = " + $1.str_tamanho + " + " + $3.str_tamanho + "; \n";
							$$.traducao += aux_var2 + " = " + aux_var1 + " * sizeof(char); \n";
							$$.traducao += aux_var3 + " = " + $1.str_tamanho + " * sizeof(char); \n";

							$$.traducao += aux_var4 + " = (char*) malloc( " + aux_var2 + " ); \nstrcpy( " + aux_var4 + ", " + $1.label + " ); \n";
							$$.traducao += aux_var5 + " = " + aux_var4 + " + " + aux_var3 + "; \nstrcpy( " + aux_var5 + ", " + $3.label + " ); \n";
							$$.traducao += $$.label + " = (char*) malloc( " + aux_var2 + " ); \nstrcpy( " + $$.label + ", " + aux_var4 + " ); \n";

						} else{
							yyerror("ERRO: Não é possivel realizar operações aritméticas entre estes tipos de expressões.");

						}
						
					} else{
						yyerror("ERRO: Não é possivel realizar operações aritméticas entre estes tipos de expressões.");
					}
				}
			}
			| E TK_OP_ARI_MD E
			{
				// + - * /
				$$.label = cria_nome_tmp();
				$$.traducao = $1.traducao + $3.traducao;

				// para numeros
				if(($1.tipo_var == "int" || $1.tipo_var == "float") && ($3.tipo_var == "int" || $3.tipo_var == "float")){
					if($1.tipo_var == $3.tipo_var){
						$$.tipo_var = $1.tipo_var;

						declaracaoAddVar(traducao_tipo($$), $$.label);
						$$.traducao += $$.label + " = " + $1.label + " " + $2.label + " " + $3.label + "; \n";
					} else{
						$$.tipo_var = "float";
						if($1.tipo_var == "float"){
							string aux_var = cria_nome_tmp();

							declaracaoAddVar(traducao_tipo($$), aux_var);
							declaracaoAddVar(traducao_tipo($$), $$.label);
							$$.traducao += aux_var + " = (float) " + $3.label + "; \n";
							$$.traducao += $$.label + " = " + $1.label + " " + $2.label + " " + aux_var + "; \n";
						} else{
							string aux_var = cria_nome_tmp();

							declaracaoAddVar(traducao_tipo($$), aux_var);
							declaracaoAddVar(traducao_tipo($$), $$.label);
							$$.traducao += aux_var + " = (float) " + $1.label + "; \n";
							$$.traducao += $$.label + " = " + aux_var + " " + $2.label + " " + $3.label + "; \n";
						}
					}
				}
			}
			| E TK_OP_LOG E
			{
				// && ||
				// MUDEI bool para int
				$$.label = cria_nome_var();
				$$.tipo_var = "bool";
				$$.traducao = $1.traducao + $3.traducao;
				if($1.tipo_var == "bool" && $3.tipo_var == "bool" && $2.label != "!"){
					declaracaoAddVar(traducao_tipo($$), $$.label);
					$$.traducao += $$.label + " = " + $1.label + " " + $2.label + " " + $3.label + "; \n";
				} else{
					if($2.label != "!"){
						yyerror("ERRO: Esta operação lógica deve ser realizada entre duas expressões.");
					} else{
						yyerror("ERRO: Operações lógicas devem ser realizadas entre expressões de tipo bool.");
					}
				}
			}
			| TK_OP_LOG E
			{
				// !
				// MUDEI bool para int
				$$.tipo_var = "bool";
				$$.label = cria_nome_var();
				$$.traducao = $2.traducao;
				if($2.tipo_var == "bool" && $1.label == "!"){
					declaracaoAddVar(traducao_tipo($$), $$.label);
					$$.traducao += $$.label + " = !" + $2.label + "; \n";
				} else{
					if($1.label != "!"){
						yyerror("ERRO: Esta operação lógica não pode ser realizada entre duas expressões.");
					} else{
						yyerror("ERRO: Operações lógicas devem ser realizadas com expressões de tipo bool.");
					}
				}

			}
			| OP_RELACIONAL
			| TK_ID
			{
				$$ = mapaGetVar($1);
				$$.traducao = "";
				if($$.label == "!morsa"){
					yyerror("ERRO: Esta variavel morsa esta em extincao");
				}

			}
			| PRIMITIVA
			;

PRIMITIVA	: TK_NUM
			{
				//$$ = $1;
				$$.tipo_var = $1.tipo_var;
				$$.label = cria_nome_tmp();
				declaracaoAddVar(traducao_tipo($$), $$.label);
				$$.traducao = $$.label + " = " + $1.label + "; \n";
			}
			| TK_REAL
			{
				//$$ = $1;
				$$.tipo_var = $1.tipo_var;
				$$.label = cria_nome_tmp();
				declaracaoAddVar(traducao_tipo($$), $$.label);
				$$.traducao = $$.label + " = " + $1.label + "; \n";
			}
			| TK_CHAR
			{
				//$$ = $1;
				$$.tipo_var = $1.tipo_var;
				$$.label = cria_nome_tmp();
				declaracaoAddVar(traducao_tipo($$), $$.label);
				$$.traducao = $$.label + " = " + $1.label + "; \n";
			}
			| TK_BOOL
			{
				//$$ = $1;
				$$.tipo_var = $1.tipo_var;
				$$.label = cria_nome_tmp();
				string aux_var;
				if($1.label == "true" || $1.label == "1"){
					aux_var = "1";
				} else{
					aux_var = "0";
				}
				declaracaoAddVar(traducao_tipo($$), $$.label);
				$$.traducao = $$.label + " = " + aux_var + "; \n";
			}
			| TK_STRING
			{
				//$$ = $1;
				$$.tipo_var = $1.tipo_var;
				$$.label = cria_nome_tmp();
				$$.str_tamanho = to_string($1.label.size()-2);
				declaracaoAddVar(traducao_tipo($$), $$.label);
				$$.traducao = $$.label + " = (char*) malloc(" + $$.str_tamanho + " * sizeof(char)); \nstrcpy( " + $$.label + ", " + $1.label + "); \n";
			}
			;

			// MUDEI de bool para int
OP_RELACIONAL 	: E TK_OP_REL E 	//OPERAÇÕES RELACIONAIS
			{
				// > >= < <= == !=
				printf("FAZENDO OPERAÇÃO RELACIONAL\n");
				$$.tipo_var = "bool";
				$$.label = cria_nome_tmp();
				$$.traducao = $1.traducao + $3.traducao;

				if($1.tipo_var == $3.tipo_var){ //caso sejam de tipos iguais
					if($2.label == "==" || $2.label == "!="){
						declaracaoAddVar(traducao_tipo($$), $$.label);
						$$.traducao += $$.label + " = " + $1.label + $2.label + $3.label + "; \n";
					} else{
						if($1.tipo_var == "char" || $1.tipo_var == "float" || $1.tipo_var == "int" ){
							declaracaoAddVar(traducao_tipo($$), $$.label);
							$$.traducao += $$.label + " = " + $1.label + $2.label + $3.label + "; \n";
						}
					}

					//printf("Operacao relacional entre tipos iguais\n");

				} else{ //caso sejam de tipos diferentes
					if($1.tipo_var == "int" && $3.tipo_var == "float"){
						string aux_var1 = traducao_tipo($3);
						string aux_var2 = cria_nome_tmp();

						declaracaoAddVar(aux_var1, aux_var2);
						declaracaoAddVar(traducao_tipo($$), $$.label);
						$$.traducao += aux_var2 + " = (" + aux_var1 + ") " + $1.label + "; \n";
						$$.traducao += $$.label + " = " + aux_var2 + $2.label + $3.label + "; \n";

					} else if($1.tipo_var == "float" && $3.tipo_var == "int"){
						string aux_var1 = traducao_tipo($1);
						string aux_var2 = cria_nome_tmp();

						declaracaoAddVar(aux_var1, aux_var2);
						declaracaoAddVar(traducao_tipo($$), $$.label);
						$$.traducao += aux_var2 + " = (" + aux_var1 + ") " +  $3.label + "; \n";
						$$.traducao += $$.label + " = " + $1.label + $2.label + aux_var2 + "; \n";

					} else{
						yyerror("ERRO: Não é possível realizar esta operação entres estes tipos de variáveis.");
					}
					printf("Operacao relacional entre tipos diferentes\n");
				}
			}
			;

ATTR 		: TK_ID TK_ATTR E       	//TK_ATTR -> = *= /= += == ++ --
			{ 	// TEMOS QUE ALTERAR AQUI??
				//TK_ATTR é o token de atribuicao, neste caso o yylval.label pode ser = += -= *= /=
				$$ = mapaGetVar($1);

				if($$.label == "!morsa"){
					yyerror("ERRO: Não existe uma variável com este nome.");
				} else if($3.str_tamanho == "!morsa"){ 
					yyerror("ERRO: Deve ser atribuido um valor à variável para utiliza-la na atribuição de valor de outra variável.");
				} else{
					if($2.label == "="){
						if($$.tipo_var == "string" && $3.tipo_var == "string"){
							if($3.str_tamanho != "!morsa"){
								$$.traducao = $3.traducao;
								if($$.str_tamanho == "!morsa"){
									string aux_var = cria_nome_tmp();

									declaracaoAddVar("int", aux_var);
									$$.traducao += aux_var + " = " + $3.str_tamanho + " * sizeof(char); \n";
									$$.traducao += $$.label + " = (char*) malloc( " + aux_var + " ); \n";
								} else{
									string aux_var1 = cria_nome_tmp();
									string aux_var2 = cria_nome_tmp();

									declaracaoAddVar("int", aux_var1);
									declaracaoAddVar("int", aux_var2);
									$$.traducao += aux_var1 + " = " + $$.str_tamanho + " + " + $3.str_tamanho + "; \n";
									$$.traducao += aux_var2 + " = " + aux_var1 + " * sizeof(char); \n";
									$$.traducao += $$.label + " = (char*) realloc( " + $$.label + ", " + aux_var2 + " ); \n";

								}
								$$.traducao += "strcpy(" + $$.label + ", " + $3.label + "); \n";

								mapaSetTam($1.label, $3.str_tamanho);

							} else{
								yyerror("ERRO: Deve ser atribuido um valor à variável para utiliza-la na atribuição de valor de outra variável.");
							}
						} else{
							$$.traducao = $3.traducao;

							if($$.tipo_var == $3.tipo_var){
								$$.traducao += $$.label + " = " + $3.label + "; \n";

							} else if($$.tipo_var == "!morsa"){
								mapaSetTipo($$.nome_var, $3.tipo_var);
								declaracaoAddVar($3.tipo_var, $$.label);
								$$.traducao += $$.label + " = " + $3.label + "; \n";
							}else{
								if(isConvertivel($$, $3)){
									string aux_var1 = traducao_tipo($$);
									string aux_var2 = cria_nome_tmp();

									declaracaoAddVar(aux_var1, aux_var2);
									$$.traducao += aux_var2 + " = (" + aux_var1 + ") " + $3.label + "; \n";
									$$.traducao += $$.label + " = " + aux_var2 + "; \n";
								} else{
									yyerror("ERRO: Os tipos das variáveis ou expressões não são compatíveis para atribuição.");

								}
							}
							mapaSetTam($1.label, "-1");
						}

					} else{
						if($$.str_tamanho != "!morsa"){
							if(($$.tipo_var == "int" || $$.tipo_var == "float") && ($3.tipo_var == "int" || $3.tipo_var == "float")){
								
								$$.traducao = $3.traducao;

								if($$.tipo_var == $3.tipo_var){

									if($2.label == "*="){
										$$.traducao += $$.label + " = " + $$.label + " * " + $3.label + "; \n";

									} else if($2.label == "/="){
										$$.traducao += $$.label + " = " + $$.label + " / " + $3.label + "; \n";

									} else if($2.label == "+="){
										$$.traducao += $$.label + " = " + $$.label + " + " + $3.label + "; \n";

									} else if($2.label == "-="){
										$$.traducao += $$.label + " = " + $$.label + " - " + $3.label + "; \n";

									} else{
										yyerror("ERRO: A operação de atribuição não é válida.");
									}

								} else{

									string aux_var1 = traducao_tipo($$);
									string aux_var2 = cria_nome_tmp();

									if($2.label == "*="){
										declaracaoAddVar(aux_var1, aux_var2);
										$$.traducao += aux_var2 + " = (" + aux_var1 + ") " + $3.label + "; \n";
										$$.traducao += $$.label + " = " + $$.label + " * " + aux_var2 + "; \n";

									} else if($2.label == "/="){
										if($$.tipo_var == "int"){
											string aux_var3 = cria_nome_tmp();

											declaracaoAddVar("float", aux_var2);
											declaracaoAddVar("float", aux_var3);
											$$.traducao += aux_var2 + " = (float) " + $$.label + "; \n";
											$$.traducao += aux_var3 + " = " + aux_var2 + " / " + $3.label + "; \n";
											$$.traducao += $$.label + " = (" + aux_var1 + ") " + aux_var3 + "; \n";

										} else{
											declaracaoAddVar(aux_var1, aux_var2);
											$$.traducao += aux_var2 + " = (" + aux_var1 + ") " + $3.label + "; \n";
											$$.traducao += $$.label + " = " + $$.label + " / " + aux_var2 + "; \n";

										}

									} else if($2.label == "+="){
										declaracaoAddVar(aux_var1, aux_var2);
										$$.traducao += aux_var2 + " = (" + aux_var1 + ") " + $3.label + "; \n";
										$$.traducao += $$.label + " = " + $$.label + " + " + aux_var2 + "; \n";

									} else if($2.label == "-="){
										declaracaoAddVar(aux_var1, aux_var2);
										$$.traducao += aux_var2 + " = (" + aux_var1 + ") " + $3.label + "; \n";
										$$.traducao += $$.label + " = " + $$.label + " - " + aux_var2 + "; \n";

									} else{
										yyerror("ERRO: A operação de atribuição não é válida.");
									}

								}
							} else {
								yyerror("ERRO: Os tipos das variáveis ou expressões não são válidos para a operação (ao menos uma não é float ou int).");
							}
						} else {
								yyerror("ERRO 1: Deve ser atribuido um valor à variável para utilizar este tipo de atribuição.");
						}
					}
				}

				printf("ATRIBUI VALOR A VARIAVEL\n");

			}
			| DECLARACAO TK_ATTR E
			{
				if($2.label == "="){
					if($3.str_tamanho != "!morsa"){
						if($$.tipo_var == "string" && $3.tipo_var == "string"){
							$$.traducao = $1.traducao + $3.traducao;
							if($1.str_tamanho == "!morsa"){
								string aux_var = cria_nome_tmp();

								declaracaoAddVar("int", aux_var);
								$$.traducao += aux_var + " = " + $3.str_tamanho + " * sizeof(char); \n";
								$$.traducao += $$.label + " = (char*) malloc( " + aux_var + " ); \n";
							
							} else{
								string aux_var1 = cria_nome_tmp();
								string aux_var2 = cria_nome_tmp();

								declaracaoAddVar("int", aux_var1);
								declaracaoAddVar("int", aux_var2);
								$$.traducao += aux_var1 + " = " + $$.str_tamanho + " + " + $3.str_tamanho + "; \n";
								$$.traducao += aux_var2 + " = " + aux_var1 + " * sizeof(char); \n";
								$$.traducao += $$.label + " = (char*) realloc( " + $$.label + ", " + aux_var2 + " ); \n";

							}
							$$.traducao += "strcpy(" + $$.label + ", " + $3.label + "); \n";

							//$$.str_tamanho = $3.str_tamanho;
							mapaSetTam($1.nome_var, $3.str_tamanho);

						} else{
							$$.traducao = $1.traducao + $3.traducao;

							if($$.tipo_var == $3.tipo_var){
								$$.traducao += $$.label + " = " + $3.label + "; \n";

							} else{
								if(isConvertivel($$, $3)){
									string aux_var1 = traducao_tipo($$);
									string aux_var2 = cria_nome_tmp();

									declaracaoAddVar(aux_var1, aux_var2);
									$$.traducao += aux_var2 + " = (" + aux_var1 + ") " + $3.label + "; \n";
									$$.traducao += $$.label + " = " + aux_var2 + "; \n";
								} else{
									yyerror("ERRO: Os tipos das variáveis ou expressões não são compatíveis para atribuição.");

								}
							}

							mapaSetTam($1.nome_var, "-1");
						}
					} else{
						yyerror("ERRO: Deve ser atribuido um valor à variável para utiliza-la na atribuição de valor de outra variável.");
					}

				} else{
					yyerror("ERRO: Esta atribuição não pode ser realizada.");
				}


				printf("ATRIBUI VALOR A VARIAVEL\n");
			}
			| TK_ID TK_ATTR
			{
				//TK_ATTR, neste caso, neste caso o yylval.label pode ser ++ --
				$$ = mapaGetVar($1);

				if($$.label == "!morsa"){
					yyerror("ERRO: Não existe uma variável com este nome.");
				} else if($$.str_tamanho == "!morsa"){
					yyerror("ERRO 2: Deve ser atribuido um valor à variável para utilizar este tipo de atribuição.");
				}else{
					if($2.label == "++"){
						if($$.tipo_var == "int"){
							$$.traducao = $$.label + " = " + $$.label + " + 1; \n";

						} else if($$.tipo_var == "float"){
							$$.traducao = $$.label + " = " + $$.label + " + 1.0; \n";

						} else{
							yyerror("ERRO: A variável não é do tipo numérico (int ou float)");
						}

					} else if($2.label == "--"){
						if($$.tipo_var == "int"){
							$$.traducao = $$.label + " = " + $$.label + " - 1; \n";

						} else if($$.tipo_var == "float"){
							$$.traducao = $$.label + " = " + $$.label + " - 1.0; \n";

						} else{
							yyerror("ERRO: A variável não é do tipo numérico (int ou float)");
						}

					} else{
						yyerror("ERRO: Operação de atribuição não está completa (está faltando uma variável ou expressão para ser atribuida à variável especificada).");
					}
				}


				printf("ATRIBUI VALOR A VARIAVEL\n");
			}
			;

/*
VET_INDEX	: TK_ABRECOLCH E TK_FECHACOLCH
			{
				if($2.tipo_var == "int"){
					$$.label = cria_nome_tmp();
					$$.tipo_var = "int";
					$$.traducao = $2.traducao;
					$$.traducao += $$.tipo_var + " " + $$.label + " = (int) " + $2.label + "; \n";
					seqIndex.push_back($$.label);
				} else {
					yyerror("ERRO: O valor do índice de uma matriz/vetor deve se inteiro.");					
				}

			}

MAT_INDEX	: VET_INDEX MAT_INDEX
			{
				$$.label = cria_nome_tmp();
				$$.tipo_var = "int";
				$$.traducao = $1.traducao + $2.traducao;
				$$.traducao += $$.tipo_var + " " + $$.label + " = (int) (" + $1.label + " * " + $2.label + "); \n";
			}
			| 
			{
				$$.traducao = "";
			}
			;
VET_VALUES	: E TK_COMMA VET_VALUES
			{

			}
			| E
			;

MAT_VALUES	: MAT_VALUES TK_COMMA MAT_VALUES
			{

			}
			| TK_ABRECHAV MAT_VALUES TK_FECHACHAV
			{

			}
			| MAT_VALUES
			| VET_VALUES
			;	

VET_ATTR	: TK_ATTR TK_ABRECHAV VET_VALUES TK_FECHACHAV
			{

			}
			;	

MAT_ATTR	: TK_ATTR TK_ABRECHAV MAT_VALUES TK_FECHACHAV
			{

			}
			;
*/

DECLARACAO	: TK_TIPO TK_ID
			{
				$$ = mapaGetVar($2);

				if($$.label == "!morsa"){
					$$.label = cria_nome_var();
					$$.nome_var = $2.label;
					$$.tipo_var = $1.label;
					declaracaoAddVar(traducao_tipo($$), $$.label, false);
					$$.traducao = "";

					$$.str_tamanho = "!morsa";

					mapasAddVar($$);
				} else{
					yyerror("ERRO: Já existe uma variável com este nome.");
				}


				printf("DECLAREI UMA VARIAVEL\n");
			}
			| TK_TIPO_INFERIDO TK_ID TK_ATTR E
			{
				if($3.label == "="){
					$$ = mapaGetVar($2);

					if($$.label == "!morsa"){
						$$.label = cria_nome_var();
						$$.nome_var = $2.label;
						$$.tipo_var = $4.tipo_var;
						$$.traducao = $4.traducao;
						declaracaoAddVar(traducao_tipo($$), $$.label, false);
						$$.traducao += $$.label + " = " + $4.label + "; \n";

						if($4.tipo_var == "string"){
							$$.str_tamanho = $4.str_tamanho;
						} else{
							$$.str_tamanho = "";							
						}
						
						mapasAddVar($$);
					} else{
						yyerror("ERRO: Já existe uma variável com este nome.");
					}
				} else{
					yyerror("ERRO: Este sinal de atribuicao nao é permitido");
				}

				printf("DECLAREI UMA VARIAVEL\n");
			}
			| TK_TIPO_INFERIDO TK_ID
			{
				$$ = mapaGetVar($2);

				if($$.label == "!morsa"){
					$$.label = cria_nome_var();
					$$.nome_var = $2.label;
					$$.tipo_var = "!morsa";
					$$.str_tamanho = "";
					declaracaoAddVar("!morsa", $$.label, false);
					
					mapasAddVar($$);
				} else{
					yyerror("ERRO: Já existe uma variável com este nome.");
				}
				printf("DECLAREI UMA VARIAVEL\n");
			}
			/*
			| TK_TIPO TK_ID VET_INDEX
			{

				$$ = mapaGetVar($2);

				if($$.label == "!morsa"){
					$$.label = cria_nome_var();
					$$.nome_var = $2.label;
					$$.tipo_var = $1.label + "*";

					string aux_var1 = cria_nome_tmp();

					$$.traducao = $3.traducao;
					$$.traducao += $$.label + " = (" + $$.tipo_var + ") malloc(" + $3.label + " * sizeof(" + $1.label + ")); \n";
					$$.traducao += aux_var1 + " = (int*) malloc(" + to_string(seqIndex.size()) + " * sizeof(int)); \n";

					for(int i = 0; i < seqIndex.size(); i++){
						$$.traducao += aux_var1 + "[" + to_string(i) + "] = " + seqIndex[i] + "; \n";
					}

					seqIndex.clear();

					$$.str_tamanho = "!morsa";

					mapasAddVar($$);
					declaracaoAddVar(traducao_tipo($$), $$.label);
					declaracaoAddVar("int*", aux_var1);

				} else{
					yyerror("ERRO: Já existe uma variável com este nome.");
				}
			}
			*/
			;

PRINT		: TK_PRINT TK_COLON PRINT_EXPS
			{
				printf("IMPRIMINDO TIPOS DIFERENTES\n");
				$$.traducao = $3.traducao;
				$$.traducao += "cout" + $3.label + "; \n";
			}
			;

PRINTLN		: TK_PRINTLN TK_COLON PRINT_EXPS
			{
				printf("IMPRIMINDO TIPOS DIFERENTES\n");
				$$.traducao = $3.traducao;
				$$.traducao += "cout" + $3.label + " << endl; \n";
			}
			;

PRINT_EXPS	: E PRINT_EXPS
			{
				$$.traducao = $1.traducao + $2.traducao;
				$$.label = " << " + $1.label + $2.label;
			}
			| E
			{
				$$.traducao = $1.traducao;
				$$.label = " << " + $1.label;
			}
			;

SCAN		: TK_ID TK_COLON TK_SCAN
			{
				atributos aux_var1;

				aux_var1 = mapaGetVar($1);
				int aux_var2 = 100 * sizeof(char);

				if(aux_var1.label != "!morsa"){
					$$.traducao = aux_var1.traducao;
					if(aux_var1.tipo_var == "string" && aux_var1.str_tamanho == "!morsa"){
						$$.traducao += aux_var1.label + " = (char*) malloc(" + to_string(aux_var2) + "); \n";
					}
					printf("SCAN ENTRADA DO USUARIO\n");
					$$.traducao += "cin >> " + aux_var1.label + "; \n";
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
