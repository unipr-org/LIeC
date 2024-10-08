cmake_minimum_required(VERSION 3.10)
project(CPM_Lexer)

# Imposta il compilatore
set(CMAKE_C_COMPILER gcc)
set(CMAKE_C_FLAGS "-Wall -Wextra")

# Definisci i nomi dei file
set(CPM_LEXER_FLEX ${CMAKE_SOURCE_DIR}/cpm-lexer.ll)
set(CPM_LEXER_C ${CMAKE_SOURCE_DIR}/cpm-lexer.c)
set(CPM_LEXER_BIN cpm-lexer)

# Trova Flex
find_package(FLEX REQUIRED)

# Genera il file C da Flex
FLEX_TARGET(CPMLexer ${CPM_LEXER_FLEX} ${CPM_LEXER_C})

# Aggiungi l'eseguibile
add_executable(${CPM_LEXER_BIN} ${FLEX_CPMLexer_OUTPUTS})

# Link alla libreria Flex
target_link_libraries(${CPM_LEXER_BIN} -lfl)

# Obiettivo per eseguire i test
file(GLOB CPM_FILES ${CMAKE_SOURCE_DIR}/test/*.cpm)  # Trova tutti i file .cpm

add_custom_target(test
    COMMAND ${CMAKE_COMMAND} -E echo "Esecuzione dei test con i file .cpm nella cartella test"
    COMMAND ${CMAKE_COMMAND} -E echo "Inizio test..."
)

foreach(CPM_FILE ${CPM_FILES})
    add_custom_command(
        TARGET test
        COMMAND ${CMAKE_BINARY_DIR}/${CPM_LEXER_BIN} < "${CPM_FILE}"
				COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --green "Test completato per ${CPM_FILE}"
        DEPENDS ${CPM_LEXER_BIN}
        COMMENT "Esecuzione del test per ${CPM_FILE}"
    )
endforeach()
