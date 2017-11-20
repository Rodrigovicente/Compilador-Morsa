#CALL = make all nome=teste.morsa
all:
		clear
		lex lexica.l
		yacc -d sintatica.y
		g++ -std=c++0x -o glf y.tab.c -lfl

		./glf < ${nome}.morsa
		g++ intermed.cpp -o intermed
		./intermed


osx:
		clear
		lex lexica.l
		yacc -d sintatica.y
		g++ -std=c++0x -o glf y.tab.c -ll

		./glf < ${nome}.morsa
		g++ intermed.cpp -o intermed
		./intermed

clean:
	test -f morsao && rm morsao
	test -f *.o && rm *.o
	test -f *tab.c && rm *tab.c
	test -f *tab.h && rm *tab.h
	test -f *yy.c && rm *yy.c
	test -f inte*.c && rm inte*.c
