#CALL = make all nome=teste.morsa
all:
		clear
		lex lexica.l
		yacc -d sintatica.y
		g++ -o glf y.tab.c -lfl

		./glf < $(nome)
