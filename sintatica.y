%{
#include <iostream>
#include <string>
#include <sstream>
#include <vector>

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

int* mapasContemVar(atributos variavel){
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
				saida = pilhaMapas[i].attrs[j];
				//saida.nome_var = pilhaMapas[i].attrs[j].nome_var;
				//saida.traducao = "";
				return saida;
			}
		}
	}

	saida.label = "!morsa";
	return saida;

}

bool mapasAddVar(atributos variavel){
  int *aux;
  aux = mapasContemVar(variavel);
	if(aux[0] != -1){
		pilhaMapas[aux[1]].attrs.push_back(variavel);
		return true;
	} else{
		return false;
	}
}

void mapaPushVar(atributos variavel){
	pilhaMapas[pilhaMapas.size() - 1].attrs.push_back(variavel);
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

string int_to_float(atributos attr){
  	string result;

  	result = attr.label + ".0";

  	return result;
}

  //testar as duas

/*string float_to_int(atributos attr){
  	int i;
    std::string result;
    for(i = 0; i < attr.label.size() - 1; i++){
      if(attr.label[i] == "."){
        result = attr.label.substr (0,i);
        break;
      }
    }
    return result;
  }
  */


	string float_to_int(atributos attr){
		if(attr.tipo_var == "float"){
            int i;
            string resultado = "";
			for(i = 0; i< attr.label.size() - 1; i++){
				if(attr.label[i] == '.'){
					return resultado;
				} else {
					resultado += attr.label[i];
				}
			}
        } else{
			return NULL;
        }

  }

  string charToInt(atributos attr)
  {
      string result;
      if(attr.tipo_var == "char"){
		 			char letra = attr.label[0];
          result = to_string((int) letra);
      } else{
          result = "";
      }
      return result;
  }
  string charToFloat(atributos attr)
  {
      string result;
      if(attr.tipo_var == "char"){
          char letra = attr.label[0];
          result = to_string((int) letra);
          result += ".0";
      } else{
          result = "";
      }
      return result;
  }

string remove_aspas(string text){
    if(text[0] == '\"' && text[text.size() - 1] == '\"'){
        string result = text.substr(1, text.size() - 2);
        return result;
    } else{
        return NULL;
    }
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
%token TK_ID
%token TK_BOOL
%token TK_NUM
%token TK_CHAR
%token TK_STRING
%token TK_REAL
%token TK_TIPO TK_TIPO_INFERIDO
//%token TK_FIM TK_ERROR
//%token TK_PRINT
%token TK_COM_IF
%token TK_COM_ELSE
%token TK_COM_WHILE
%token TK_COM_FOR
%token TK_COM_DO
%token TK_ATTR


%start S

%left '+'

%%

S 			: INIT_BLOCO BLOCO END_BLOCO
			{
				cout << "/*Compilador MORSA*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nusing namespace std;\nint main(void)\n{\n" << $1.traducao << "\treturn 0;\n}" << endl;
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
				$$.traducao = $3.traducao;
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
  			;
		//	| BL_CONDICIONAL
		//	| BL_LOOP
			
/*
BL_CONDICIONAL : TK_COM_IF '(' CONDICAO ')' INIT_BLOCO BLOCO END_BLOCO
			{
				// IF
			}
			| TK_COM_IF '(' CONDICAO ')' INIT_BLOCO BLOCO END_BLOCO TK_COM_ELSE INIT_BLOCO BLOCO END_BLOCO
			{
				// IF ELSE
			}
			| TK_COM_IF '(' CONDICAO ')' INIT_BLOCO BLOCO END_BLOCO TK_COM_ELSE BL_CONDICIONAL_ELSEIF
			{
				// IF ELSE IF
			}
			| TK_COM_SWITCH '(' TK_ID ')' '{' BL_CONDICIONAL_SWITCH TK_COM_DEFAULT ':' INIT_BLOCO END_BLOCO
      {
        // SWITCH (INCOMPLETO, TEM QUE ENTENDER COMO FUNCIONA)
      }
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

BL_LOOP		: INIT_BLOCO TK_COM_WHILE '(' CONDICAO ')' BLOCO END_BLOCO
			{
				// WHILE
			}
			| INIT_BLOCO TK_COM_FOR '(' ATTR ';' CONDICAO ';' ATTR ')' BLOCO END_BLOCO
			{
				// FOR
			}
			| INIT_BLOCO TK_COM_DO BLOCO TK_COM_WHILE '(' CONDICAO ')' END_BLOCO
			{
				// DO... WHILE
			}
			;*/
E 			: '(' E ')'
			{
				$$.traducao = $2.traducao;
			}
			| TK_CAST E
			{
          	// Casting // peida de mudar o casting para outra coisa? tipo (parseInt) (parseFloat) (parseChar) sei la. algo para não ficar muito C LIKE
              /*
              	com parentesiiiiiiiiiiiiiiiiiiiiiiiiiis, não é melhor?
              	int var;
                var = int: 1.5; << esse é melhor kkkkkk eu sei, mas fica muito C like vamos dar uma divertida na parada. tipo (MorsaInt) KKK
                a indentação tá uma merda
              */
            	$$.label = cria_nome_var();
            	$$.traducao = $2.traducao;

				if($1.label == "(int)"){
					if($2.tipo_var == "float"){
                    	$$.tipo_var = "int";
                    	string aux_var = cria_nome_tmp();
                    	$$.traducao += "int " + aux_var + "; \n" + aux_var + " = " + float_to_int($2) + "; \n int " + $$.label + " = " + aux_var + "; \n";
                      
                    } else if($2.tipo_var == "int"){
                      	$$.tipo_var = "int";
                      	$$.traducao += "int " + $$.label + "; \n" + $$.label + " = " + $2.label + "; \n";

                    } else if($2.tipo_var == "char"){
                    	$$.tipo_var = "int";
                      	string aux_var = cria_nome_tmp();
						$$.traducao += "int " + aux_var + "; \n" + aux_var + " = " + charToInt($2) + "; \n int"  + $$.label + " = " + aux_var + "; \n";
                      
                    } else{
                     	yyerror("ERROR: Não é possível realizar a conversão para este tipo.");
                    }

				} else if($1.label == "(float)"){
                	if($2.tipo_var == "int"){
						$$.tipo_var = "float";
                      	string aux_var = cria_nome_tmp();
                      	$$.traducao += "float " + aux_var + "; \n" + aux_var + " = " + int_to_float($2) + "; \n int " + $$.label + " = " + aux_var + "; \n";

                	} else if($2.tipo_var == "float"){
                      	$$.tipo_var = "float";
                      	$$.traducao += "float " + $$.label + "; \n" + $$.label + " = " + $2.label + "; \n";
                    } else if($2.tipo_var == "char"){
						$$.tipo_var = "float";
                      	string aux_var = cria_nome_tmp();
						$$.traducao += "float " + aux_var + "; \n" + aux_var + " = " + charToInt($2) + "; \n int"  + $$.label + " = " + aux_var + "; \n";
                    } else{
                     	yyerror("ERROR: Não é possível realizar a conversão para este tipo.");
                    }
                } else{ // caso cast (char)
                	if($2.tipo_var == "int" || $2.tipo_var == "float"){
                    	$$.tipo_var = "char";
						$$.traducao += "char " + $$.label + "; \n" + $$.label + " = " + charToFloat($2) + "; \n";
                    } else{
                     	yyerror("ERROR: Não é possível realizar a conversão para este tipo.");
                    }
                }

      }
			| E TK_OP_ARI E
			{
				// + - * /
				$$.label = cria_nome_var();
				$$.traducao = $1.traducao + $3.traducao;

				// para numeros
				if(($1.tipo_var == "int" || $1.tipo_var == "float") && ($3.tipo_var == "float" || $3.tipo_var == "int")){
					if($1.tipo_var == $3.tipo_var){
						$$.tipo_var = $1.tipo_var;
						$$.traducao += $$.tipo_var + " " + $$.label + "; \n" + $$.label + " = " + $1.label + " " + $2.label + " " + $3.label + "; \n";
					} else{
						if($1.tipo_var == "float"){
							string aux_var = cria_nome_tmp();
							$$.traducao += "float " + aux_var + "; \n" + aux_var + " = " + int_to_float($3) + "; \n";
							$$.traducao += "float " + $$.label + "; \n" + $$.label + " = " + $1.label + " " + $3.label + " " + aux_var + "; \n";
						} else{
							string aux_var = cria_nome_tmp();
							$$.traducao += "float " + aux_var + "; \n" + aux_var + " = " + int_to_float($1) + "; \n";
							$$.traducao += "float " + $$.label + "; \n" + $$.label + " = " + $1.label + " " + $3.label + " " + aux_var + "; \n";
						}
					}
                }
              	// para char e string (concatenacao)
              	else if(($1.tipo_var == "char" || $1.tipo_var == "char*") && ($3.tipo_var == "char" || $3.tipo_var == "char*")){
                	if($2.label == "+"){
                		//if($1.tipo_var == $3.tipo_var){ Não faz diferença! Todos vao virar string.
						$$.tipo_var = "char*";
                      	// Talvez seja necessário mudar para string. -> Warning C++
                    	$$.traducao += "char* " + $$.label + "; \n" + $$.label + " = " + "\"" + $1.label + $3.label + "\"" + "; \n";
						//}
                    }
                }
			}
			| E TK_OP_LOG E
			{
				// && ||
                $$.tipo_var = "bool";
                $$.traducao = $1.traducao + $2.traducao;
				if($1.tipo_var == "bool" && $3.tipo_var == "bool" && $2.label != "!"){
                	$$.traducao += "bool " + $$.label + "; \n" + $$.label + " = " + $1.label + " " + $2.label + " " + $3.label + "; \n";
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
              	$$.tipo_var = "bool";
                $$.traducao = $2.traducao;
				if($1.tipo_var == "bool" && $2.label == "!"){
                	$$.traducao += "bool " + $$.label + "; \n" + $$.label + " =  !" + $2.label + "; \n";
				} else{
                    if($2.label != "!"){
						yyerror("ERRO: Esta operação lógica não pode ser realizada entre duas expressões.");
                    } else{
						yyerror("ERRO: Operações lógicas devem ser realizadas com expressões de tipo bool.");
                    }
				}

            }
			| CONDICAO
			| TK_ID
			{
				$$ = mapaGetVar($1);
				if($$.label == "!morsa"){
					yyerror("ERRO: Esta variavel morsa esta em extincao");
				}

			}
			| TK_NUM
			{
				$$ = $1;
				$$.label = cria_nome_var();
              	$$.tipo_var = "int";
				$$.traducao =  $1.tipo_var + " " + $$.label + "; \n" + $$.label + " = " + $1.label + "; \n";
			}
			| TK_REAL
			{
				$$ = $1;
				$$.label = cria_nome_var();
              	$$.tipo_var = "float";
				$$.traducao =  $1.tipo_var + " " + $$.label + "; \n" + $$.label + " = " + $1.label + "; \n";
			}
			| TK_CHAR
			{
              	$$.tipo_var = "char";
				$$ = $1;
				$$.label = cria_nome_var();
				$$.traducao =  $1.tipo_var + " " + $$.label + "; \n" + $$.label + " = " + $1.label + "; \n";
			}
			| TK_BOOL
			{
              	$$.tipo_var = "bool";
				$$ = $1;
				$$.label = cria_nome_var();
				$$.traducao = $1.tipo_var + " " + $$.label + "; \n" + $$.label + " = " + $1.label + "; \n";
			}
			| TK_STRING
			{
              	$$.tipo_var = "char*";
				$$ = $1;
				$$.label = cria_nome_var();
              	//string aux_var = remove_aspas($1.label);
              	//como o itoa não funciona, teremos de mudar
              	// itoa($1.label.size() - 2)
				$$.traducao = "char* " + $$.label + "; \n" + $$.label + " = malloc(" + to_string($1.label.size() -2) + " * sizeof(char)); \n" + $$.label + " = " + $1.label + "; \n";
			}
			;

CONDICAO 	: E TK_OP_REL E 	//OPERAÇÕES RELACIONAIS
			{
				// > >= < <= == !=
				$$.tipo_var = "bool";
				$$.label = cria_nome_var();
                $$.traducao = $1.traducao + $3.traducao;

				if($1.tipo_var == $3.tipo_var){ //caso sejam de tipos iguais
					if($2.label == "==" || $2.label == "!="){
						$$.traducao += "bool " + $$.label + "; \n" + $$.label + " = " + $1.label + $2.label + $3.label + "; \n";
					} else{
						if($1.tipo_var == "char" || $1.tipo_var == "float" || $1.tipo_var == "int" ){
							$$.traducao += "bool " + $$.label + "; \n" + $$.label + " = " + $1.label + $2.label + $3.label + "; \n";
						}
					}

				} else{ //caso sejam de tipos diferentes
					if(($1.tipo_var == "int" && $3.tipo_var == "float") || ($1.tipo_var == "float" && $3.tipo_var == "int")){
						$$.traducao += "bool " + $$.label + "; \n" + $$.label + " = " + $1.label + $2.label + $3.label + "; \n";
                    } else{
                    	yyerror("ERRO: Não é possível realizar esta operações entres estes tipos de variáveis.");
                    }
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
						$$.traducao = $3.traducao;
						$$.traducao += $$.label + " = " + $3.label + "; \n";

						/*
                        	CONTINUAR
							DÚVIDA: nesta parte de atribuição pode ser usado a conversão implicita do C, ou se o E tiver um tipo diferendo do TK_ID deve ser
							feita uma conversão?
						*/

					} else{
						if(($1.tipo_var == "int" || $1.tipo_var == "float") && ($3.tipo_var == "int" || $3.tipo_var == "float")){
							if($2.label == "*="){
								$$.traducao = $3.traducao;
								$$.traducao += $$.label + " = " + $$.label + " * " + $3.label + "; \n";
							} else if($2.label == "/="){
								$$.traducao = $3.traducao;
								$$.traducao += $$.label + " = " + $$.label + " / " + $3.label + "; \n";
							} else if($2.label == "+="){
								$$.traducao = $3.traducao;
								$$.traducao += $$.label + " = " + $$.label + " + " + $3.label + "; \n";
							} else if($2.label == "-="){
								$$.traducao = $3.traducao;
								$$.traducao += $$.label + " = " + $$.label + " - " + $3.label + "; \n";
							} else{
								yyerror("ERRO: A operação de atribuição não é válida.");
							}
						} else {
							yyerror("ERRO: Os tipos das variáveis ou expressões não são válidos para a operação (ao menos uma não é float ou int).");
						}
					}
				}

			}
			| DECLARACAO TK_ATTR E
			{
				if($2.label == "="){
					$$.traducao = $3.traducao;
					$$.traducao += $$.label + " = " + $3.label + "; \n";

						/*
                        	CONTINUAR
							DÚVIDA: nesta parte de atribuição pode ser usado a conversão implicita do C, ou se o E tiver um tipo diferendo do TK_ID deve ser
							feita uma conversão?
						*/

                } else{
                	yyerror("ERRO: Esta atribuição não pode ser realizada.");
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
			;
DECLARACAO	: TK_TIPO TK_ID
			{
				$$ = mapaGetVar($2);

				if($$.label == "!morsa"){
					$$.tipo_var = $1.label;
					$$.nome_var = $2.label;
					$$.label = cria_nome_var();
                  	$$.traducao = $$.tipo_var + " " + $$.label + "; \n";
					mapasAddVar($$);
				} else{
					yyerror("ERRO: Já existe uma variável com este nome.");
				}
			}
			| TK_TIPO_INFERIDO TK_ID "=" E
			{
				$$ = mapaGetVar($2);

				if($$.label == "!morsa"){
					$$.nome_var = $2.label;
					$$.label = cria_nome_var();
                    $$.tipo_var = $4.tipo_var;
					$$.traducao = $4.traducao;
                    $$.traducao += $$.tipo_var + " " + $$.label + "; \n" + $$.label + " = " + $4.label + "; \n";
					mapasAddVar($$);
				} else{
					yyerror("ERRO: Já existe uma variável com este nome.");
				}
			}
			| TK_TIPO_INFERIDO TK_ID
			{
				yyerror("ERRO: Você deve atribuir um valor a esta variável para inferir o seu tipo.");
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
