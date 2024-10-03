CC = gcc
CFLAGS = -Wall -Wextra

CPM_LEXER_FLEX = cpm-lexer.flex
CPM_LEXER_C = cpm-lexer.c
CPM_LEXER_BIN = cpm-lexer

all: ${CPM_LEXER_C} ${CPM_LEXER_BIN}

${CPM_LEXER_C}:
	flex -o ${CPM_LEXER_C} ${CPM_LEXER_FLEX}

${CPM_LEXER_BIN}: ${CPM_LEXER_C}
	${CC} ${CFLAGS} ${CPM_LEXER_C} -o ${CPM_LEXER_BIN} -lfl

clean:
	rm ${CPM_LEXER_C} ${CPM_LEXER_BIN}
