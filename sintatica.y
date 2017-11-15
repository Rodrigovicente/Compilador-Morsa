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
};

typedef struct mapaVar mapaVariaveis;

static int count_vars = 0;
static int count_tmps = 0;
static int count_rots = 0;

vector<mapaVariaveis> pilhaMapas;
vector<atributos> pilhaDeclaracao;


// relação tipo em morsa - tipo em c
map<string,string> relacaoTipos = 	{
										{"int","int"},
										{"float","float"},
										{"char","char"},
										{"bool","int"},
										{"string","char*"}
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

void declaraoAddVar(atributos variavel){
	
	pilhaDeclaracao.push_back(variavel);

	printf("ADICIONEI PARA DECLARAR: %s - total: %d\n",pilhaDeclaracao[pilhaDeclaracao.size()-1].nome_var.c_str(), pilhaDeclaracao.size());

}

bool mapasAddVar(atributos variavel){
  	bool aux;
  	aux = mapasContemVar(variavel);
	if(!aux){
		pilhaMapas[pilhaMapas.size()-1].attrs.push_back(variavel);
		printf("ADICIONEI NO MAPA: %d\n",pilhaMapas[pilhaMapas.size()-1].attrs.size() );

		declaraoAddVar(variavel);
		return true;
	} else{
		printf("NAO ADICIONEI NO MAPA\n" );
		return false;
	}
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




void mapaPushVar(atributos variavel){
	pilhaMapas[pilhaMapas.size() - 1].attrs.push_back(variavel);
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
%token TK_COM_DEFAULT TK_COM_WHILE TK_COM_FOR TK_COM_DO TK_CAST TK_OP_ARI TK_OP_LOG TK_STRING TK_OP_REL TK_ATTR TK_TIPO TK_TIPO_INFERIDO*/

%token TK_COM_SWITCH
//%token TK_CASE
%token TK_COM_DEFAULT
%token TK_OP_ARI
%token TK_OP_REL
%token TK_OP_LOG
%token TK_CAST
%token TK_BOOL
%token TK_ID
%token TK_NUM
%token TK_CHAR
%token TK_STRING
%token TK_REAL
%token TK_TIPO
%token TK_TIPO_INFERIDO
//%token TK_FIM TK_ERROR
//%token TK_PRINT
%token TK_COM_IF
%token TK_COM_ELSE
%token TK_COM_WHILE
%token TK_COM_FOR
%token TK_COM_DO
%token TK_ATTR
%token TK_PRINT
%token TK_ENDL

%nonassoc TK_COM_IF


%start S


%left '='
%left "||" "&&"
%left "==" "!="
%left '<' '>' ">=" "<="
%left '+' '-'
%left '*' '/'


%%

S 			: INIT_BLOCO BLOCO END_BLOCO
			{
  				string out = "/*Compilador MORSA*/ \n #include <iostream>\n#include <string.h>\n#include<string.h>\n#include<stdio.h>\nusing namespace std;\nint main(void)\n{\n" + $2.traducao + "\n \t return 0;\n}\n";
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
				pilhaMapas.push_back(mapVar);

				$$.start_block_lb = mapVar.start_block_lb;
				$$.end_block_lb = mapVar.end_block_lb;

				printf("+++CRIEI UM MAPA com rotulo: %s\n", pilhaMapas[pilhaMapas.size()-1].start_block_lb.c_str() );
			}
			;
END_BLOCO	:
			{
				printf("---TIREI UM MAPA com rotulo: %s\n", pilhaMapas[pilhaMapas.size()-1].start_block_lb.c_str() );
				pilhaMapas.pop_back();
			}

BLOCO		: '{' COMANDOS '}'
			{
				$$.traducao = $2.traducao;
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

COMANDO 	: E ';'
			| DECLARACAO ';'
			| ATTR ';'
			| PRINT ';'
			| BL_CONDICIONAL
			| BL_LOOP
  			;

CONDICAO 	: E
			{
				if($1.tipo_var == "bool"){
					$$ = $1;
				} else {
					yyerror("ERRO: A condição do IF só aceita expressões do tipo bool.");
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
/*
BL_CONDICIONAL_ELSEIF : TK_COM_IF '(' CONDICAO ')' INIT_BLOCO BLOCO TK_COM_ELSE BL_CONDICIONAL_ELSEIF
			{
              	$$.end_block_lb = $8.end_block_lb;
  				
				string ini_label = pilhaMapas[pilhaMapas.size() - 1].start_block_lb;
  				string end_label = pilhaMapas[pilhaMapas.size() - 1].end_block_lb;
  				string end_label_elseif = $8.end_block_lb;
  
                $$.traducao =  $3.traducao;
  				$$.traducao += $1.label + "(" + $3.label + ") goto " + ini_label + ";\n" + "goto " + end_label + ";\n";
                $$.traducao += "\n" + ini_label + ": \n" + $6.traducao + "goto " + end_label_elseif + "; \n\n" + end_label + ": \n";
  
				$$.traducao += $8.traducao;
  	
			}
			| TK_COM_IF '(' CONDICAO ')' INIT_BLOCO BLOCO END_BLOCO
			{
				string ini_label = pilhaMapas[pilhaMapas.size() - 1].start_block_lb;
  				string end_label = pilhaMapas[pilhaMapas.size() - 1].end_block_lb;
              	
              	$$.end_block_lb = end_label;
              
                $$.traducao =  $3.traducao;
  				$$.traducao += $1.label + "(" + $3.label + ") goto " + ini_label + ";\n" + "goto " + end_label + ";\n";
                $$.traducao += "\n" + ini_label + ": \n" + $6.traducao + "\n" + end_label + ": \n";
			}
			| TK_COM_IF '(' CONDICAO ')' INIT_BLOCO BLOCO TK_COM_ELSE INIT_BLOCO BLOCO
			{
				string ini_label_else = pilhaMapas[pilhaMapas.size() - 1].start_block_lb;
  				string end_label_else = pilhaMapas[pilhaMapas.size() - 1].end_block_lb;
				
              	$$.end_block_lb = end_label_else;
              
				pilhaMapas.pop_back();

				string ini_label_if = pilhaMapas[pilhaMapas.size() - 1].start_block_lb;
  				string end_label_if = pilhaMapas[pilhaMapas.size() - 1].end_block_lb;

                $$.traducao = $3.traducao;
  				$$.traducao += $1.label + "(" + $3.label + ") goto " + ini_label_if + ";\n" + "goto " + ini_label_else + ";\n";
                $$.traducao += "\n" + ini_label_if + ": \n" + $6.traducao + "goto " + end_label_else + "; \n\n" + ini_label_else + ": \n" + $9.traducao + "\n" + end_label_else + ": \n";

				pilhaMapas.pop_back();
			}
			;
*/

BL_LOOP		: INIT_BLOCO TK_COM_WHILE '(' CONDICAO ')' BLOCO END_BLOCO
			{
				string ini_label = pilhaMapas[pilhaMapas.size() - 1].start_block_lb;
  				string end_label = pilhaMapas[pilhaMapas.size() - 1].end_block_lb;
  
  				// Temos que pensar em iterar a condição 

  				/*
					
					int i = 0;
					while(i < 10){
						i++;
					}



					rot_1:

					int tmp_0;
					int tmp_1;
					int tmp_3;
					tmp_0 = var_0;
					tmp_1 = 10;
					tmp_3 = tmp_0 < tmp_1;

					if(tmp_3) goto rot_2;
					goto rot_3;
					
					rot_2:
						//....
					goto rot_1;

					rot_3:
					
					
					
					
					
					
					
					
					
					
					
					
  				*/

			}
			| INIT_BLOCO TK_COM_FOR '(' ATTR ';' CONDICAO ';' ATTR ')' BLOCO END_BLOCO
			{
				// FOR
			}
			| INIT_BLOCO TK_COM_DO BLOCO TK_COM_WHILE '(' CONDICAO ')' END_BLOCO
			{
				// DO... WHILE
			}
			;

E 			: '(' E ')'
			{
				$$.traducao = $2.traducao;
			}
			| TK_CAST E
			{
            	$$.label = cria_nome_var();
            	$$.traducao = $2.traducao;

				if($1.label == "(int)"){
                    $$.tipo_var = "int";
					if($2.tipo_var == "float"){
                    	string aux_var = cria_nome_tmp();

                    	$$.traducao += traducao_tipo($$) + " " + aux_var + "; \n" + aux_var + " = (int) " + $2.label + "; \n";
                    	$$.traducao += "int " + $$.label + "; \n" + $$.label + " = " + aux_var + "; \n";

                    } else if($2.tipo_var == "int"){
                      	$$.traducao += traducao_tipo($$) + " " + $$.label + "; \n" + $$.label + " = " + $2.label + "; \n";

                    } else if($2.tipo_var == "char"){
                      	string aux_var = cria_nome_tmp();
						$$.traducao += traducao_tipo($$) + " " + aux_var + "; \n" + aux_var + " = (int) " + $2.label + "; \n";
						$$.traducao += traducao_tipo($$) + " "  + $$.label + "; \n" + $$.label + " = " + aux_var + "; \n";

                    } else{
                     	yyerror("ERROR: Não é possível realizar a conversão para este tipo.");
                    }

				} else if($1.label == "(float)"){
                    $$.tipo_var = "float";
                	if($2.tipo_var == "int"){
                      	string aux_var = cria_nome_tmp();
                      	$$.traducao += traducao_tipo($$) + " " + aux_var + "; \n" + aux_var + " = (float) " + $2.label + "; \n";
                      	$$.traducao += traducao_tipo($$) + " " + $$.label + "; \n" + $$.label + " = " + aux_var + "; \n";

                	} else if($2.tipo_var == "float"){
                      	$$.traducao += traducao_tipo($$) + " " + $$.label + "; \n" + $$.label + " = " + $2.label + "; \n";
                    } else if($2.tipo_var == "char"){
                      	string aux_var = cria_nome_tmp();
						$$.traducao += traducao_tipo($$) + " " + aux_var + "; \n" + aux_var + " = (float) " + $2.label + "; \n";
						$$.traducao += traducao_tipo($$) + " " + $$.label + "; \n" + $$.label + " = " + aux_var + "; \n";
                    } else{
                     	yyerror("ERROR: Não é possível realizar a conversão para este tipo.");
                    }
                } else{ // caso cast (char)
                    $$.tipo_var = "char";
                	if($2.tipo_var == "int" ){
                      	string aux_var = cria_nome_tmp();
						$$.traducao += "char " + aux_var + "; \n" + aux_var + " = (char) " + $2.label + "; \nint "  + $$.label + "; \n" + $$.label + " = " + aux_var + "; \n";
                    } else if($2.tipo_var == "float"){
                      	string aux_var1 = cria_nome_tmp();
                      	string aux_var2 = cria_nome_tmp();

						$$.traducao += "int " + aux_var1 + "; \n" + aux_var1 + " = (int) " + $2.label + "; \n";
						$$.traducao += "char " + aux_var2 + "; \n" + aux_var2 + " = (char) " + aux_var1 + "; \n";
						$$.traducao += "char "  + $$.label + "; \n" + $$.label + " = " + aux_var2 + "; \n";

                    } else{
                     	yyerror("ERROR: Não é possível realizar a conversão para este tipo.");
                    }
                }

            }
			| E TK_OP_ARI E
			{
				// + - * /
				$$.label = cria_nome_tmp();
				$$.traducao = $1.traducao + $3.traducao;

				// para numeros
				if(($1.tipo_var == "int" || $1.tipo_var == "float") && ($3.tipo_var == "int" || $3.tipo_var == "float")){
					if($1.tipo_var == $3.tipo_var){
						$$.tipo_var = $1.tipo_var;
						$$.traducao += $$.tipo_var + " " + $$.label + "; \n" + $$.label + " = " + $1.label + " " + $2.label + " " + $3.label + "; \n";
					} else{
						$$.tipo_var = "float";
						if($1.tipo_var == "float"){
							string aux_var = cria_nome_tmp();
							$$.traducao += "float " + aux_var + "; \n" + aux_var + " = (float) " + $3.label + "; \n";
							$$.traducao += "float " + $$.label + "; \n" + $$.label + " = " + $1.label + " " + $2.label + " " + aux_var + "; \n";
						} else{
							string aux_var = cria_nome_tmp();
							$$.traducao += "float " + aux_var + "; \n" + aux_var + " = (float) " + $1.label + "; \n";
							$$.traducao += "float " + $$.label + "; \n" + $$.label + " = " + aux_var + " " + $2.label + " " + $3.label + "; \n";
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

							$$.traducao += "int " + aux_var1 + "; \n" + aux_var1 + " = " + $1.str_tamanho + " + " + $3.str_tamanho + "; \n";
							$$.traducao += "int " + aux_var2 + "; \n" + aux_var2 + " = " + aux_var1 + " * sizeof(char); \n";
							$$.traducao += "int " + aux_var3 + "; \n" + aux_var3 + " = " + $1.str_tamanho + " * sizeof(char); \n";

                			$$.traducao += "char* " + aux_var4 + "; \n" + aux_var4 + " = (char*) malloc( " + aux_var2 + " ); \nstrcpy( " + aux_var4 + ", " + $1.label + " ); \n";
                			$$.traducao += "char* " + aux_var5 + "; \n" + aux_var5 + " = " + aux_var4 + " + " + aux_var3 + "; \nstrcpy( " + aux_var5 + ", " + $3.label + " ); \n";
							$$.traducao += "char* " + $$.label + "; \n" + $$.label + " = (char*) malloc( " + aux_var2 + " ); \nstrcpy( " + $$.label + ", " + aux_var4 + " ); \n";
							$$.traducao += "free(" + aux_var4 + "); \n";

                		} else{
                    		yyerror("ERRO: Não é possivel realizar operações aritméticas entre estes tipos de expressões.");

                		}
						
                    } else{
                    	yyerror("ERRO: Não é possivel realizar operações aritméticas entre estes tipos de expressões.");
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
                	$$.traducao += traducao_tipo($$) + " " + $$.label + "; \n" + $$.label + " = " + $1.label + " " + $2.label + " " + $3.label + "; \n";
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
                	$$.traducao += traducao_tipo($$) + " " + $$.label + "; \n" + $$.label + " = !" + $2.label + "; \n";
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
				$$.label = cria_nome_tmp();
              	$$.tipo_var = "int";
				$$.traducao = $1.tipo_var + " " + $$.label + "; \n" + $$.label + " = " + $1.label + "; \n";
			}
			| TK_REAL
			{
				//$$ = $1;
              	$$.tipo_var = "float";
				$$.label = cria_nome_tmp();
				$$.traducao = traducao_tipo($$) + " " + $$.label + "; \n" + $$.label + " = " + $1.label + "; \n";
			}
			| TK_CHAR
			{
				//$$ = $1;
              	$$.tipo_var = "char";
				$$.label = cria_nome_tmp();
				$$.traducao = traducao_tipo($$) + " " + $$.label + "; \n" + $$.label + " = " + $1.label + "; \n";
			}
			| TK_BOOL
			{
				//$$ = $1;
              	$$.tipo_var = "bool";
				$$.label = cria_nome_tmp();
				string aux_var;
				if($1.label == "true" || $1.label == "1"){
					aux_var = "1";
				} else{
					aux_var = "0";
				}
				$$.traducao = traducao_tipo($$) + " " + $$.label + "; \n" + $$.label + " = " + aux_var + "; \n";
			}
			| TK_STRING
			{
				//$$ = $1;
              	$$.tipo_var = "string";
				$$.label = cria_nome_tmp();
				$$.str_tamanho = to_string($1.label.size() -2);
				$$.traducao = traducao_tipo($$) + " " + $$.label + "; \n" + $$.label + " = (char*) malloc(" + $$.str_tamanho + " * sizeof(char)); \nstrcpy( " + $$.label + ", " + $1.label + "); \n";
			}
			;

			// MUDEI de bool para int
OP_RELACIONAL 	: E TK_OP_REL E 	//OPERAÇÕES RELACIONAIS
			{
				// > >= < <= == !=
				$$.tipo_var = "bool";
				$$.label = cria_nome_tmp();
                $$.traducao = $1.traducao + $3.traducao;

				if($1.tipo_var == $3.tipo_var){ //caso sejam de tipos iguais
					if($2.label == "==" || $2.label == "!="){
						$$.traducao += traducao_tipo($$) + " " + $$.label + "; \n" + $$.label + " = " + $1.label + $2.label + $3.label + "; \n";
					} else{
						if($1.tipo_var == "char" || $1.tipo_var == "float" || $1.tipo_var == "int" ){
							$$.traducao += traducao_tipo($$) + " " + $$.label + "; \n" + $$.label + " = " + $1.label + $2.label + $3.label + "; \n";
						}
					}

					printf("Operacao relacional entre tipos iguais\n");

				} else{ //caso sejam de tipos diferentes
					if($1.tipo_var == "int" && $3.tipo_var == "float"){
						string aux_var1 = traducao_tipo($3);
						string aux_var2 = cria_nome_tmp();

						$$.traducao += aux_var1 + " " + aux_var2 + "; \n" + aux_var2 + " = (" + aux_var1 + ") " +  $1.label + "; \n";
						$$.traducao += traducao_tipo($$) + " " + $$.label + "; \n" + $$.label + " = " + aux_var2 + $2.label + $3.label + "; \n";

					} else if($1.tipo_var == "float" && $3.tipo_var == "int"){
						string aux_var1 = traducao_tipo($1);
						string aux_var2 = cria_nome_tmp();

						$$.traducao += aux_var1 + " " + aux_var2 + "; \n" + aux_var2 + " = (" + aux_var1 + ") " +  $3.label + "; \n";
						$$.traducao += traducao_tipo($$) + " " + $$.label + "; \n" + $$.label + " = " + $1.label + $2.label + aux_var2 + "; \n";

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
				} else{
					if($2.label == "="){
						if($$.tipo_var == "string" && $3.tipo_var == "string"){
							$$.traducao = $3.traducao;
							if($$.str_tamanho == "!morsa"){
								string aux_var = cria_nome_tmp();

								$$.traducao += "int " + aux_var + "; \n" + aux_var + " = " + $3.str_tamanho + " * sizeof(char); \n";
								$$.traducao += $$.label + " = (char*) malloc( " + aux_var + " ); \n";
							} else{
								string aux_var1 = cria_nome_tmp();
								string aux_var2 = cria_nome_tmp();

								$$.traducao += "int " + aux_var1 + "; \n" + aux_var1 + " = " + $$.str_tamanho + " + " + $3.str_tamanho + "; \n";
								$$.traducao += "int " + aux_var2 + "; \n" + aux_var2 + " = " + aux_var1 + " * sizeof(char); \n";
								$$.traducao += $$.label + " = (char*) realloc( " + $$.label + ", " + aux_var2 + " ); \n";

							}
							if($3.traducao == ""){
								$$.traducao += "strcpy(" + $$.label + ", " + $3.label + "); \n";

							} else{
								$$.traducao += "strcpy(" + $$.label + ", " + $3.label + "); \nfree(" + $3.label + "); \n";

							}

							mapaSetTam($1.label, $3.str_tamanho);

						} else{
							$$.traducao = $3.traducao;

							if($$.tipo_var == $3.tipo_var){
								$$.traducao += $$.label + " = " + $3.label + "; \n";

							} else{
								if(isConvertivel($$, $3)){
									string aux_var1 = traducao_tipo($$);
									string aux_var2 = cria_nome_tmp();

									$$.traducao += aux_var1 + " " + aux_var2 + "; \n" + aux_var2 + " = (" + aux_var1 + ") " + $3.label + "; \n";
									$$.traducao += $$.label + " = " + aux_var2 + "; \n";
								} else{
									yyerror("ERRO: Os tipos das variáveis ou expressões não são compatíveis para atribuição.");

								}
							}
						}

					} else{
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
									$$.traducao += aux_var1 + " " + aux_var2 + "; \n" + aux_var2 + " = (" + aux_var1 + ") " + $3.label + "; \n";
									$$.traducao += $$.label + " = " + $$.label + " * " + aux_var2 + "; \n";

								} else if($2.label == "/="){
									if($$.tipo_var == "int"){
										string aux_var3 = cria_nome_tmp();

										$$.traducao += "float " + aux_var2 + "; \n" + aux_var2 + " = (float) " + $$.label + "; \n";
										$$.traducao += "float " + aux_var3 + "; \n" + aux_var3 + " = " + aux_var2 + " / " + $3.label + "; \n";
										$$.traducao += $$.label + " = (" + aux_var1 + ") " + aux_var3 + "; \n";

									} else{
										$$.traducao += aux_var1 + " " + aux_var2 + "; \n" + aux_var2 + " = (" + aux_var1 + ") " + $3.label + "; \n";
										$$.traducao += $$.label + " = " + $$.label + " / " + aux_var2 + "; \n";

									}

								} else if($2.label == "+="){
									$$.traducao += aux_var1 + " " + aux_var2 + "; \n" + aux_var2 + " = (" + aux_var1 + ") " + $3.label + "; \n";
									$$.traducao += $$.label + " = " + $$.label + " + " + aux_var2 + "; \n";

								} else if($2.label == "-="){
									$$.traducao += aux_var1 + " " + aux_var2 + "; \n" + aux_var2 + " = (" + aux_var1 + ") " + $3.label + "; \n";
									$$.traducao += $$.label + " = " + $$.label + " - " + aux_var2 + "; \n";

								} else{
									yyerror("ERRO: A operação de atribuição não é válida.");
								}

							}
						} else {
							yyerror("ERRO: Os tipos das variáveis ou expressões não são válidos para a operação (ao menos uma não é float ou int).");
						}
					}
				}

				printf("ATRIBUI VALOR A VARIAVEL\n");

			}
			| DECLARACAO TK_ATTR E
			{
				if($2.label == "="){
					if($$.tipo_var == "string" && $3.tipo_var == "string"){
						$$.traducao = $1.traducao + $3.traducao;
						if($$.str_tamanho == "!morsa"){
							string aux_var = cria_nome_tmp();

							$$.traducao += "int " + aux_var + "; \n" + aux_var + " = " + $3.str_tamanho + " * sizeof(char); \n";
							$$.traducao += $$.label + " = (char*) malloc( " + aux_var + " ); \n";
						
						} else{
							string aux_var1 = cria_nome_tmp();
							string aux_var2 = cria_nome_tmp();

							$$.traducao += "int " + aux_var1 + "; \n" + aux_var1 + " = " + $$.str_tamanho + " + " + $3.str_tamanho + "; \n";
							$$.traducao += "int " + aux_var2 + "; \n" + aux_var2 + " = " + aux_var1 + " * sizeof(char); \n";
							$$.traducao += $$.label + " = (char*) realloc( " + $$.label + ", " + aux_var2 + " ); \n";

						}
						if($3.traducao == ""){
							$$.traducao += "strcpy(" + $$.label + ", " + $3.label + "); \n";

						} else{
							$$.traducao += "strcpy(" + $$.label + ", " + $3.label + "); \nfree(" + $3.label + "); \n";

						}

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

								$$.traducao += aux_var1 + " " + aux_var2 + "; \n" + aux_var2 + " = (" + aux_var1 + ") " + $3.label + "; \n";
								$$.traducao += $$.label + " = " + aux_var2 + "; \n";
							} else{
								yyerror("ERRO: Os tipos das variáveis ou expressões não são compatíveis para atribuição.");

							}
						}
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
				} else{
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

DECLARACAO	: TK_TIPO TK_ID
			{
				$$ = mapaGetVar($2);

				if($$.label == "!morsa"){
					$$.label = cria_nome_var();
					$$.nome_var = $2.label;
					$$.tipo_var = $1.label;
          			$$.traducao = traducao_tipo($$) + " " + $$.label + "; \n";

					if($1.label == "string"){
          				$$.str_tamanho = "!morsa";
					}

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
	                    $$.traducao += traducao_tipo($$) + " " + $$.label + "; \n" + $$.label + " = " + $4.label + "; \n";

						if($4.tipo_var == "string"){
	          				$$.str_tamanho = $4.str_tamanho;
						}
	                    
						mapasAddVar($$);
					} else{
						yyerror("ERRO: Já existe uma variável com este nome.");
					}
				} else{
					yyerror("ERRO: Este sinal de atribuicao nao é permitido");
				}

				printf("DECLAREI UMA VARIAVEL\n");
			}/*
			| TK_TIPO_INFERIDO TK_ID
			{
				yyerror("ERRO: Você deve atribuir um valor a esta variável para inferir o seu tipo.");
			}*/
			;

PRINT	: TK_PRINT E
		{
			$$.traducao = $2.traducao;
			$$.traducao += "cout << " + $2.label + " << endl; \n";

			if($2.traducao != ""){
				$$.traducao += "free(" + $2.label + "); \n";

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
