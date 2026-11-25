# Project: KeywordHighlighter
# Makefile created by Dev-C++ 7.1

CPP      = g++.exe
CC       = gcc.exe
WINDRES  = windres.exe
OBJ      = main.o
LINKOBJ  = main.o
LIBS     = -m32 -no-pie -nostdlib
INCS     = 
CXXINCS  = 
BIN      = KeywordHighlighter.exe
CXXFLAGS = $(CXXINCS) -m32 -Wall -Wextra -pedantic -no-pie -nostdlib
CFLAGS   = $(INCS) -m32 -std=gnu11 -Wall -Wextra -pedantic -no-pie -nostdlib
RM       = del /q

.PHONY: all all-before all-after clean clean-custom

all: all-before $(BIN) all-after

clean: clean-custom
	${RM} $(OBJ) $(BIN)

$(BIN): $(OBJ)
	$(CPP) $(LINKOBJ) -o $(BIN) $(LIBS)

main.o: main.cpp
	$(CPP) -c main.cpp -o main.o $(CXXFLAGS)
