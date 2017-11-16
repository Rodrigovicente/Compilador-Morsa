#CALL = make all nome=teste.morsa
all:
		clear
		lex lexica.l
		yacc -d sintatica.y
		g++ -std=c++0x -o glf y.tab.c -lfl

		./glf < teste.morsa
		g++ intermed.cpp -o intermed
		./intermed

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
