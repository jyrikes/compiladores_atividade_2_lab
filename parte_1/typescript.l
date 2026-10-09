%option noyywrap yylineno nodefault noinput nounput
%x COMENTARIO STRING TEMPLATE

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>

enum Token {
    TOK_ERRO = 256,
    TOK_KEYWORD, TOK_RESERVADA_RESTRITA, TOK_CONTEXTUAL, TOK_LITERAL,
    TOK_NUMBER, TOK_BIGINT, TOK_STRING, TOK_IDENTIFICADOR, TOK_ID_PRIVADO,
    TOK_ARITMETICO, TOK_INCREMENTO, TOK_RELACIONAL, TOK_IGUALDADE,
    TOK_LOGICO, TOK_BITWISE, TOK_DESLOCAMENTO, TOK_ATRIBUICAO,
    TOK_CONDICIONAL, TOK_ACESSO, TOK_SETA, TOK_SPREAD,
    TOK_PONTO_VIRGULA, TOK_DELIMITADOR, TOK_DECORADOR,
    TOK_COMENTARIO, TOK_HASHBANG,
    TOK_TEMPLATE_ABRE, TOK_TEMPLATE_TEXTO, TOK_TEMPLATE_FECHA,
    TOK_INTERPOLACAO_ABRE, TOK_INTERPOLACAO_FECHA
};

static int erros = 0;
static int linha_inicio = 1;
static int aspas_abertura = 0;
static double numero_atual = 0.0;
static char *bigint_atual = NULL;

static char *buffer = NULL;
static size_t buffer_tam = 0, buffer_cap = 0;

static int pilha_chaves[64];
static int topo_chaves = -1;

static void limpar_buffer(void) {
    buffer_tam = 0;
    if (buffer) buffer[0] = '\0';
}

static void anexar(const char *texto, size_t n) {
    if (buffer_tam + n + 1 > buffer_cap) {
        size_t nova = buffer_cap ? buffer_cap : 128;
        while (nova < buffer_tam + n + 1) nova *= 2;
        char *p = realloc(buffer, nova);
        if (!p) { perror("realloc"); exit(EXIT_FAILURE); }
        buffer = p;
        buffer_cap = nova;
    }
    memcpy(buffer + buffer_tam, texto, n);
    buffer_tam += n;
    buffer[buffer_tam] = '\0';
}

static int emitir(int token, const char *categoria, const char *texto) {
    printf("linha %-4d | %-21s | %s\n", yylineno, categoria, texto);
    return token;
}

static int emitir_na_linha(int token, const char *categoria, const char *texto, int linha) {
    printf("linha %-4d | %-21s | %s\n", linha, categoria, texto);
    return token;
}

static int erro_na_linha(const char *motivo, const char *texto, int linha) {
    fprintf(stderr, "linha %d | ERRO_LEXICO: %s [%s]\n", linha, motivo, texto);
    erros++;
    return TOK_ERRO;
}

static int erro_lexico(const char *motivo, const char *texto) {
    fprintf(stderr, "linha %d | ERRO_LEXICO: %s [%s]\n", yylineno, motivo, texto);
    erros++;
    return TOK_ERRO;
}

static char *normalizar_numero(const char *texto, int remover_n) {
    size_t n = strlen(texto), pos = 0;
    char *limpo = malloc(n + 1);
    if (!limpo) { perror("malloc"); exit(EXIT_FAILURE); }
    for (size_t i = 0; i < n; ++i) {
        if (texto[i] == '_') continue;
        if (remover_n && i == n - 1 && texto[i] == 'n') continue;
        limpo[pos++] = texto[i];
    }
    limpo[pos] = '\0';
    return limpo;
}

static int emitir_numero(const char *texto) {
    char *limpo = normalizar_numero(texto, 0);
    int base = 10;
    if (limpo[0] == '0') {
        if (limpo[1] == 'x' || limpo[1] == 'X') base = 16;
        else if (limpo[1] == 'b' || limpo[1] == 'B') base = 2;
        else if (limpo[1] == 'o' || limpo[1] == 'O') base = 8;
    }
    errno = 0;
    if (base == 10 || base == 16) {
        numero_atual = strtod(limpo, NULL);
    } else {
        numero_atual = 0;
        for (const char *p = limpo + 2; *p; ++p) {
            int algarismo = *p - '0';
            numero_atual = numero_atual * base + algarismo;
        }
    }
    printf("linha %-4d | %-21s | %-22s => %.17g\n",
           yylineno, "NUMBER", texto, numero_atual);
    free(limpo);
    return TOK_NUMBER;
}

static int emitir_bigint(const char *texto) {
    free(bigint_atual);
    bigint_atual = normalizar_numero(texto, 1);
    printf("linha %-4d | %-21s | %-22s => %s (sem perda)\n",
           yylineno, "BIGINT", texto, bigint_atual);
    return TOK_BIGINT;
}
%}

KEYWORD             ("break"|"case"|"catch"|"class"|"const"|"continue"|"debugger"|"default"|"delete"|"do"|"else"|"enum"|"export"|"extends"|"finally"|"for"|"function"|"if"|"import"|"in"|"instanceof"|"new"|"return"|"super"|"switch"|"this"|"throw"|"try"|"typeof"|"var"|"void"|"while"|"with")
RESERVADA_RESTRITA  ("implements"|"interface"|"let"|"package"|"private"|"protected"|"public"|"static"|"yield")
CONTEXTUAL          ("abstract"|"accessor"|"as"|"assert"|"asserts"|"any"|"async"|"await"|"bigint"|"boolean"|"constructor"|"declare"|"defer"|"from"|"get"|"global"|"immediate"|"infer"|"intrinsic"|"is"|"keyof"|"module"|"namespace"|"never"|"number"|"object"|"of"|"out"|"override"|"readonly"|"require"|"satisfies"|"set"|"source"|"string"|"symbol"|"type"|"undefined"|"unique"|"unknown"|"using")
LITERAL             ("true"|"false"|"null")

DIGITO              [0-9]
NATURAL             {DIGITO}+
DIGITOS_DEC         {DIGITO}(_?{DIGITO})*
INTEIRO             (0|[1-9](_?{DIGITO})*)
FLOAT               ({INTEIRO}\.{DIGITOS_DEC}?|\.{DIGITOS_DEC})
EXPONENTE           [eE][+-]?{DIGITOS_DEC}
CIENTIFICO          ({FLOAT}|{INTEIRO}){EXPONENTE}
DIGITOS_HEX         [0-9a-fA-F](_?[0-9a-fA-F])*
DIGITOS_BIN         [01](_?[01])*
DIGITOS_OCT         [0-7](_?[0-7])*
HEXADECIMAL         0[xX]{DIGITOS_HEX}
BINARIO             0[bB]{DIGITOS_BIN}
OCTAL               0[oO]{DIGITOS_OCT}
BIGINT              ({INTEIRO}|{HEXADECIMAL}|{BINARIO}|{OCTAL})n
NUMBER              ({CIENTIFICO}|{FLOAT}|{INTEIRO}|{HEXADECIMAL}|{BINARIO}|{OCTAL})

ARITMETICO_OP       ("**"|"*"|"/"|"%"|"+"|"-")
INCREMENTO_OP       ("++"|"--")
REL_OP              ("<="|">="|"<"|">")
IGUALDADE_OP        ("==="|"!=="|"=="|"!=")
LOGICO_OP           ("&&"|"||"|"??"|"!")
BITWISE_OP          ("&"|"|"|"^"|"~")
DESLOCAMENTO_OP     (">>>"|">>"|"<<")
ATRIBUICAO          (">>>="|"<<="|">>="|"**="|"&&="|"||="|"??="|"+="|"-="|"*="|"/="|"%="|"&="|"|="|"^="|"=")
CONDICIONAL_OP      ("?"|":")
ACESSO_OP           ("?."|".")
SETA_OP             "=>"
SPREAD              "..."
PONTO_VIRGULA       ";"
DELIMITADOR         ("("|")"|"["|"]"|"{"|"}"|",")
DECORADOR           "@"
ASPAS_DUPLAS        \"
ASPAS_SIMPLES       "'"
CRASE               "`"
DELIMITADOR_STRING  ({ASPAS_DUPLAS}|{ASPAS_SIMPLES})
DELIMITADOR_TEMPLATE {CRASE}
ESCAPE_UNICODE      \\u([0-9a-fA-F]{4}|\{[0-9a-fA-F]{1,6}\})
LETRA               [a-zA-Z_$]
IDENTIFICADOR       {LETRA}({LETRA}|{DIGITO})*
IDENTIFICADOR_PRIVADO \#{IDENTIFICADOR}
STRING_DUPLA        \"([^\"\\\r\n]|\\[^\r\n]|\\(\r\n|\r|\n))*\"
STRING_SIMPLES      '([^'\\\r\n]|\\[^\r\n]|\\(\r\n|\r|\n))*'
STRING_LITERAL      ({STRING_DUPLA}|{STRING_SIMPLES})
COMENTARIO_LINHA    "//"[^\r\n]*
COMENTARIO_BLOCO    "/*"([^*]|\*+[^*/])*\*+"/"
ABRE_COMENTARIO     "/*"
FECHA_COMENTARIO    "*/"
HASHBANG            "#!"[^\r\n]*
INTERPOLACAO_INICIO "${"
NEWLINE             (\r\n|\r|\n)
ESPACO              [ \t\v\f]+

%%

^{HASHBANG} {
    if (yylineno == 1) return emitir(TOK_HASHBANG, "HASHBANG", yytext);
    return erro_lexico("hashbang fora do inicio", yytext);
}

{ESPACO}  ;
{NEWLINE} ;

{COMENTARIO_LINHA} {
    return emitir(TOK_COMENTARIO, "COMENTARIO_LINHA", yytext);
}

{ABRE_COMENTARIO} {
    linha_inicio = yylineno;
    limpar_buffer();
    anexar(yytext, yyleng);
    BEGIN(COMENTARIO);
}
<COMENTARIO>"*"+"/" {
    anexar(yytext, yyleng);
    BEGIN(INITIAL);
    return emitir_na_linha(TOK_COMENTARIO, "COMENTARIO_BLOCO", buffer, linha_inicio);
}
<COMENTARIO>[^*\r\n]+  { anexar(yytext, yyleng); }
<COMENTARIO>"*"+       { anexar(yytext, yyleng); }
<COMENTARIO>{NEWLINE}  { anexar(yytext, yyleng); }
<COMENTARIO><<EOF>> {
    BEGIN(INITIAL);
    return erro_na_linha("comentario de bloco nao fechado", "/* ...", linha_inicio);
}

<INITIAL>{DELIMITADOR_STRING}    { aspas_abertura = yytext[0]; linha_inicio = yylineno; limpar_buffer(); anexar(yytext, yyleng); BEGIN(STRING); }

<STRING>\\(\r\n|\r|\n)   { anexar(yytext, yyleng); }
<STRING>\\[^\r\n]         { anexar(yytext, yyleng); }
<STRING>[^\\'"\r\n]+      { anexar(yytext, yyleng); }
<STRING>["'] {
    anexar(yytext, yyleng);
    if (yytext[0] == aspas_abertura) {
        BEGIN(INITIAL);
        return emitir_na_linha(TOK_STRING, "STRING", buffer, linha_inicio);
    }
}
<STRING>\\             {
    BEGIN(INITIAL);
    return erro_na_linha("escape incompleto em string", buffer ? buffer : "", linha_inicio);
}
<STRING>{NEWLINE} {
    BEGIN(INITIAL);
    return erro_na_linha("string nao fechada antes da nova linha", buffer ? buffer : "", linha_inicio);
}
<STRING><<EOF>> {
    BEGIN(INITIAL);
    return erro_na_linha("string nao fechada no fim do arquivo", buffer ? buffer : "", linha_inicio);
}

<INITIAL>{DELIMITADOR_TEMPLATE} {
    BEGIN(TEMPLATE);
    return emitir(TOK_TEMPLATE_ABRE, "TEMPLATE_ABRE", yytext);
}
<TEMPLATE>"`" {
    BEGIN(INITIAL);
    return emitir(TOK_TEMPLATE_FECHA, "TEMPLATE_FECHA", yytext);
}
<TEMPLATE>"${" {
    if (topo_chaves >= 63) return erro_lexico("muitas interpolacoes aninhadas", yytext);
    pilha_chaves[++topo_chaves] = 0;
    BEGIN(INITIAL);
    return emitir(TOK_INTERPOLACAO_ABRE, "INTERPOLACAO_ABRE", yytext);
}
<TEMPLATE>\\(.|\n)  { return emitir(TOK_TEMPLATE_TEXTO, "TEMPLATE_TEXTO", yytext); }
<TEMPLATE>[^`$\\]+ { return emitir(TOK_TEMPLATE_TEXTO, "TEMPLATE_TEXTO", yytext); }
<TEMPLATE>"$"      { return emitir(TOK_TEMPLATE_TEXTO, "TEMPLATE_TEXTO", yytext); }
<TEMPLATE>\\       { return erro_lexico("escape incompleto em template", yytext); }
<TEMPLATE><<EOF>> {
    BEGIN(INITIAL);
    topo_chaves = -1;
    return erro_lexico("template nao fechado", "`");
}

"{" {
    if (topo_chaves >= 0) pilha_chaves[topo_chaves]++;
    return emitir(TOK_DELIMITADOR, "DELIMITADOR", yytext);
}
"}" {
    if (topo_chaves >= 0) {
        if (pilha_chaves[topo_chaves] == 0) {
            topo_chaves--;
            BEGIN(TEMPLATE);
            return emitir(TOK_INTERPOLACAO_FECHA, "INTERPOLACAO_FECHA", yytext);
        }
        pilha_chaves[topo_chaves]--;
    }
    return emitir(TOK_DELIMITADOR, "DELIMITADOR", yytext);
}

{BIGINT} { return emitir_bigint(yytext); }
{NUMBER} { return emitir_numero(yytext); }

0[xX][a-zA-Z0-9_]* { return erro_lexico("hexadecimal invalido", yytext); }
0[bB][a-zA-Z0-9_]* { return erro_lexico("binario invalido", yytext); }
0[oO][a-zA-Z0-9_]* { return erro_lexico("octal invalido", yytext); }
[0-9][0-9_]*(\.[0-9_]*)?([eE][+-]?[0-9_]*)?([a-zA-Z_$][a-zA-Z0-9_$]*)? {
    return erro_lexico("literal decimal invalido", yytext);
}
\.[0-9][0-9_]*([eE][+-]?[0-9_]*)?([a-zA-Z_$][a-zA-Z0-9_$]*)? {
    return erro_lexico("literal decimal invalido", yytext);
}

{KEYWORD}            { return emitir(TOK_KEYWORD, "KEYWORD", yytext); }
{RESERVADA_RESTRITA} { return emitir(TOK_RESERVADA_RESTRITA, "RESERVADA_RESTRITA", yytext); }
{CONTEXTUAL}         { return emitir(TOK_CONTEXTUAL, "CONTEXTUAL", yytext); }
{LITERAL}            { return emitir(TOK_LITERAL, "LITERAL", yytext); }
{IDENTIFICADOR_PRIVADO} { return emitir(TOK_ID_PRIVADO, "IDENTIFICADOR_PRIVADO", yytext); }
{IDENTIFICADOR}      { return emitir(TOK_IDENTIFICADOR, "IDENTIFICADOR", yytext); }
{ATRIBUICAO}         { return emitir(TOK_ATRIBUICAO, "ATRIBUICAO", yytext); }
{INCREMENTO_OP}      { return emitir(TOK_INCREMENTO, "INCREMENTO", yytext); }
{IGUALDADE_OP}       { return emitir(TOK_IGUALDADE, "IGUALDADE", yytext); }
{DESLOCAMENTO_OP}    { return emitir(TOK_DESLOCAMENTO, "DESLOCAMENTO", yytext); }
{REL_OP}             { return emitir(TOK_RELACIONAL, "RELACIONAL", yytext); }
{LOGICO_OP}          { return emitir(TOK_LOGICO, "LOGICO", yytext); }
{BITWISE_OP}         { return emitir(TOK_BITWISE, "BITWISE", yytext); }
{ARITMETICO_OP}      { return emitir(TOK_ARITMETICO, "ARITMETICO", yytext); }
{SPREAD}             { return emitir(TOK_SPREAD, "SPREAD", yytext); }
"?."[0-9]            { yyless(1); return emitir(TOK_CONDICIONAL, "CONDICIONAL", yytext); }
{ACESSO_OP}          { return emitir(TOK_ACESSO, "ACESSO", yytext); }
{SETA_OP}            { return emitir(TOK_SETA, "SETA", yytext); }
{CONDICIONAL_OP}     { return emitir(TOK_CONDICIONAL, "CONDICIONAL", yytext); }
{DECORADOR}          { return emitir(TOK_DECORADOR, "DECORADOR", yytext); }
{PONTO_VIRGULA}      { return emitir(TOK_PONTO_VIRGULA, "PONTO_VIRGULA", yytext); }
{DELIMITADOR}        { return emitir(TOK_DELIMITADOR, "DELIMITADOR", yytext); }

. { return erro_lexico("caractere nao reconhecido", yytext); }
<INITIAL><<EOF>> {
    if (topo_chaves >= 0) {
        topo_chaves = -1;
        return erro_lexico("interpolacao nao fechada", "${");
    }
    return 0;
}

%%

int main(int argc, char **argv) {
    if (argc > 2) {
        fprintf(stderr, "Uso: %s [arquivo.ts]\n", argv[0]);
        return EXIT_FAILURE;
    }
    if (argc == 2) {
        yyin = fopen(argv[1], "rb");
        if (!yyin) { perror(argv[1]); return EXIT_FAILURE; }
    }
    puts("=== ANALISADOR LEXICO DE TYPESCRIPT ===");
    int token;
    int total = 0;
    while ((token = yylex()) != 0) {
        total++;
    }
    printf("Total de tokens/eventos: %d | Erros: %d\n", total, erros);
    free(bigint_atual);
    free(buffer);
    if (argc == 2) fclose(yyin);
    return erros ? EXIT_FAILURE : EXIT_SUCCESS;
}
