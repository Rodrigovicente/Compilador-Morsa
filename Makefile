#CALL = make all nome=teste.morsa
all:
		clear
		lex lexica.l
		yacc -d sintatica.y
		g++ -std=c++0x -o glf y.tab.c -lfl

		./glf < teste.morsa

#all:
#		clear
#	#	yacc -d sintatica.y
#		g++ -std=c++0x -o morsao y.tab.c -lfl
#
#clean:
#	rm morsao
#	rm *.o
#	rm *tab.c
#	rm *tab.h
#	rm *yy.c
#
