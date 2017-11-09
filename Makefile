#CALL = make all nome=teste.morsa
all:
		clear
		lex lexica.l
		yacc -d sintatica.y
		g++ -o morsao y.tab.c -lfl

clean:
	rm glf
	rm *.o
