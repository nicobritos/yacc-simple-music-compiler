# Commands
CC = gcc
YACC = bison
LEX = flex

# Files
NAME = musicCompiler
SORTED_HASHMAP_FILE = utils/sorted_hashmap
STRING_UTILS_FILE = utils/string_utils
FILE_Y = $(NAME).y
FILE_L = $(NAME).l
LEX_OUT_FILE = lex.yy
YACC_OUT_FILE = $(NAME).tab
OUTPUT = compiler
OUTPUT_FILES_C = $(LEX_OUT_FILE).c $(YACC_OUT_FILE).c
OUTPUT_FILES_H = $(YACC_OUT_FILE).h
OUTPUT_FILES_O = $(OUTPUT_FILES_C:.c=.o) $(SORTED_HASHMAP_FILE).o $(STRING_UTILS_FILE).o
OUTPUT_FILES = $(OUTPUT_FILES_C) $(OUTPUT_FILES_H) $(OUTPUT_FILES_O) $(OUTPUT) musicCompiler.output

# Flags
YACC_FLAGS = -d
LEX_FLAGS =
YACC_DEBUG = --verbose --debug
LEX_DEBUG = -d
CC_FLAGS = -lm -pedantic -std=c99 -Wall
CC_FLAGS_MACOS = -ly

all: $(OUTPUT)
	
$(OUTPUT): $(OUTPUT_FILES_O)
	$(CC) -o $(OUTPUT) $(OUTPUT_FILES_O) $(CC_FLAGS)

$(YACC_OUT_FILE).o: $(YACC_OUT_FILE).c
	$(CC) -c $(YACC_OUT_FILE).c

$(SORTED_HASHMAP_FILE).o: $(SORTED_HASHMAP_FILE).c
	$(CC) -c $(SORTED_HASHMAP_FILE).c -o $(SORTED_HASHMAP_FILE).o

$(STRING_UTILS_FILE).o: $(STRING_UTILS_FILE).c
	$(CC) -c $(STRING_UTILS_FILE).c -o $(STRING_UTILS_FILE).o

$(LEX_OUT_FILE).o: $(LEX_OUT_FILE).c
	$(CC) -c $(LEX_OUT_FILE).c

$(LEX_OUT_FILE).c: $(YACC_OUT_FILE).h
	$(LEX) $(LEX_FLAGS) $(FILE_L)

$(YACC_OUT_FILE).h: $(YACC_OUT_FILE).c

$(YACC_OUT_FILE).c:
	$(YACC) $(YACC_FLAGS) $(FILE_Y)

debug:
	$(YACC) $(YACC_FLAGS) $(YACC_DEBUG) $(FILE_Y)
	$(LEX) $(LEX_FLAGS) $(LEX_DEBUG) $(FILE_L)
	$(CC) -o $(OUTPUT) $(LEX_OUT_FILE).c $(YACC_OUT_FILE).c $(SORTED_HASHMAP_FILE).c $(STRING_UTILS_FILE).c $(CC_FLAGS)

macos: $(FILE_Y) $(FILE_L) $(SORTED_HASHMAP_FILE).c $(STRING_UTILS_FILE).c
	$(YACC) $(YACC_FLAGS) $(FILE_Y)
	$(LEX) $(LEX_FLAGS) $(FILE_L)
	$(CC) -o $(OUTPUT) $(CC_FLAGS_MACOS) $(LEX_OUT_FILE).c $(YACC_OUT_FILE).c $(SORTED_HASHMAP_FILE).c $(STRING_UTILS_FILE).c
macos_debug:
	$(YACC) $(YACC_FLAGS) $(YACC_DEBUG) $(FILE_Y)
	$(LEX) $(LEX_FLAGS) $(LEX_DEBUG) $(FILE_L)
	$(CC) -g -o $(OUTPUT) $(CC_FLAGS_MACOS) $(LEX_OUT_FILE).c $(YACC_OUT_FILE).c $(SORTED_HASHMAP_FILE).c $(STRING_UTILS_FILE).c

clean:
	rm -f $(OUTPUT_FILES)