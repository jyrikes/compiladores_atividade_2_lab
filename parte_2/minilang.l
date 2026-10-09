%option noyywrap yylineno nodefault noinput nounput never-interactive

%x COMENTARIO_BLOCO STRING

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

enum Token {
    TOK_ERRO = 256,
    TOK_KEYWORD,
    TOK_IDENTIFICADOR,
    TOK_INTEIRO,
    TOK_REAL,
    TOK_TEXTO,
    TOK_ARITMETICO,
    TOK_RELACIONAL,
    TOK_LOGICO,
    TOK_ATRIBUICAO,
    TOK_DELIMITADOR,
    TOK_FIM_INSTRUCAO,
    TOK_COMENTARIO_LINHA,
    TOK_COMENTARIO_BLOCO
};

static int erros = 0;
static unsigned int linha_abertura = 1;
static char *buffer_lexema = NULL;
static size_t buffer_tamanho = 0;
static size_t buffer_capacidade = 0;

static void buffer_limpar(void) {
    buffer_tamanho = 0;
    if (buffer_lexema) buffer_lexema[0] = '\0';
}

static void buffer_acrescentar(const char *texto, size_t tamanho) {
    if (buffer_tamanho + tamanho + 1 > buffer_capacidade) {
        size_t nova = buffer_capacidade ? buffer_capacidade : 128;
        while (nova < buffer_tamanho + tamanho + 1) nova *= 2;
        char *p = realloc(buffer_lexema, nova);
        if (!p) { perror("realloc"); exit(EXIT_FAILURE); }
        buffer_lexema = p;
        buffer_capacidade = nova;
    }
    memcpy(buffer_lexema + buffer_tamanho, texto, tamanho);
    buffer_tamanho += tamanho;
    buffer_lexema[buffer_tamanho] = '\0';
}

static void imprimir_lexema(const char *texto) {
    for (const unsigned char *p = (const unsigned char *)texto; *p; ++p) {
        if (*p == '\n') fputs("\\n", stdout);
        else if (*p == '\r') fputs("\\r", stdout);
        else if (*p == '\t') fputs("\\t", stdout);
        else putchar(*p);
    }
}

static int emitir_na_linha(int codigo, const char *categoria,
                          const char *texto, unsigned int linha) {
    printf("linha %-4u | %-21s | ", linha, categoria);
    imprimir_lexema(texto);
    putchar('\n');
    return codigo;
}

static int emitir(int codigo, const char *categoria, const char *texto) {
    return emitir_na_linha(codigo, categoria, texto, (unsigned int)yylineno);
}

static int erro_na_linha(const char *motivo, const char *texto, unsigned int linha) {
    fflush(stdout);
    fprintf(stderr, "linha %-4u | ERRO_LEXICO: %s | ", linha, motivo);
    /* Saida de erro preserva lexema numa unica linha. */
    for (const unsigned char *p = (const unsigned char *)texto; *p; ++p) {
        if (*p == '\n') fputs("\\n", stderr);
        else if (*p == '\r') fputs("\\r", stderr);
        else if (*p == '\t') fputs("\\t", stderr);
        else fputc(*p, stderr);
    }
    fputc('\n', stderr);
    erros++;
    return TOK_ERRO;
}

static int erro_lexico(const char *motivo, const char *texto) {
    return erro_na_linha(motivo, texto, (unsigned int)yylineno);
}

static int emitir_inteiro(const char *texto) {
    errno = 0;
    unsigned long long valor = strtoull(texto, NULL, 10);
    printf("linha %-4d | %-21s | %-22s => ", yylineno, "INTEIRO", texto);
    if (errno == ERANGE) fputs("inteiro grande (lexema preservado)\n", stdout);
    else printf("%llu\n", valor);
    return TOK_INTEIRO;
}

static int emitir_real(const char *texto) {
    size_t n = strlen(texto);
    char *normalizado = malloc(n + 1);
    if (!normalizado) { perror("malloc"); exit(EXIT_FAILURE); }
    memcpy(normalizado, texto, n + 1);
    for (size_t i = 0; i < n; i++)
        if (normalizado[i] == ',') normalizado[i] = '.';
    double numero = strtod(normalizado, NULL);
    printf("linha %-4d | %-21s | %-22s => %.15g\n",
           yylineno, "REAL", texto, numero);
    free(normalizado);
    return TOK_REAL;
}
%}

DIGITO                 [0-9]
NATURAL                {DIGITO}+
INTEIRO                {NATURAL}
REAL                   {NATURAL},{NATURAL}
LETRA                  [a-zA-Z_]
IDENTIFICADOR          {LETRA}({LETRA}|{DIGITO})*

KEYWORD                ("inicio"|"fim"|"inteiro"|"real"|"texto"|"booleano"|"se"|"faz"|"senao"|"repita"|"enquanto"|"para"|"de"|"ate"|"faca"|"leia"|"mostre"|"sim"|"nao"|"retorne"|"funcao")

ARITMETICO_OP          ("+"|"-"|"*"|"/"|"%")
RELACIONAL_OP          ("=="|"!="|"<="|">="|"<"|">")
LOGICO_OP              ("&&"|"||"|"!")
ATRIBUICAO             "="
DELIMITADOR            ("("|")"|"["|"]"|"{"|"}"|";")
FIM_INSTRUCAO          "$"

COMENTARIO_LINHA       "#coment"[^\r\n]*
ABRE_COMENTARIO_BLOCO  "{---"
FECHA_COMENTARIO_BLOCO "---}"
ASPAS_TEXTO            "’"

NEWLINE                (\r\n|\n|\r)
ESPACO                 [ \t\v\f]+

%%

{ESPACO}                 ;
{NEWLINE}                ;

{COMENTARIO_LINHA}       { return emitir(TOK_COMENTARIO_LINHA, "COMENTARIO_LINHA", yytext); }

{ABRE_COMENTARIO_BLOCO}  { linha_abertura = (unsigned int)yylineno; buffer_limpar(); buffer_acrescentar(yytext, (size_t)yyleng); BEGIN(COMENTARIO_BLOCO); }
<COMENTARIO_BLOCO>{FECHA_COMENTARIO_BLOCO} { buffer_acrescentar(yytext, (size_t)yyleng); BEGIN(INITIAL); return emitir_na_linha(TOK_COMENTARIO_BLOCO, "COMENTARIO_BLOCO", buffer_lexema, linha_abertura); }
<COMENTARIO_BLOCO>{NEWLINE} { buffer_acrescentar(yytext, (size_t)yyleng); }
<COMENTARIO_BLOCO>.       { buffer_acrescentar(yytext, (size_t)yyleng); }
<COMENTARIO_BLOCO><<EOF>> { BEGIN(INITIAL); return erro_na_linha("comentario de bloco nao fechado", buffer_lexema ? buffer_lexema : "{---", linha_abertura); }

{ASPAS_TEXTO}           { linha_abertura = (unsigned int)yylineno; buffer_limpar(); buffer_acrescentar(yytext, (size_t)yyleng); BEGIN(STRING); }
<STRING>{ASPAS_TEXTO}   { buffer_acrescentar(yytext, (size_t)yyleng); BEGIN(INITIAL); return emitir_na_linha(TOK_TEXTO, "TEXTO", buffer_lexema, linha_abertura); }
<STRING>{NEWLINE}       { BEGIN(INITIAL); return erro_na_linha("string nao fechada antes de nova linha", buffer_lexema ? buffer_lexema : "’", linha_abertura); }
<STRING>.               { buffer_acrescentar(yytext, (size_t)yyleng); }
<STRING><<EOF>>         { BEGIN(INITIAL); return erro_na_linha("string nao fechada no fim do arquivo", buffer_lexema ? buffer_lexema : "’", linha_abertura); }

\"[^\"\r\n]*\"           { return erro_lexico("aspas duplas nao permitidas", yytext); }
\"[^\"\r\n]*            { return erro_lexico("aspas duplas nao permitidas", yytext); }

{REAL},{NATURAL}(,{NATURAL})*  { return erro_lexico("numero real com multiplas virgulas", yytext); }
{REAL}{IDENTIFICADOR}  { return erro_lexico("sufixo invalido no numero real", yytext); }
{NATURAL}"."{NATURAL} { return erro_lexico("ponto decimal nao permitido: use virgula", yytext); }
{NATURAL}{IDENTIFICADOR} { return erro_lexico("identificador nao pode iniciar com numero", yytext); }
{NATURAL}","           { return erro_lexico("numero real incompleto", yytext); }

{REAL}                  { return emitir_real(yytext); }
{INTEIRO}               { return emitir_inteiro(yytext); }

{KEYWORD}               { return emitir(TOK_KEYWORD, "KEYWORD", yytext); }
{IDENTIFICADOR}         { return emitir(TOK_IDENTIFICADOR, "IDENTIFICADOR", yytext); }

{RELACIONAL_OP}         { return emitir(TOK_RELACIONAL, "RELACIONAL", yytext); }
{LOGICO_OP}             { return emitir(TOK_LOGICO, "LOGICO", yytext); }
{ARITMETICO_OP}         { return emitir(TOK_ARITMETICO, "ARITMETICO", yytext); }
{ATRIBUICAO}            { return emitir(TOK_ATRIBUICAO, "ATRIBUICAO", yytext); }
{FIM_INSTRUCAO}         { return emitir(TOK_FIM_INSTRUCAO, "FIM_INSTRUCAO", yytext); }
{DELIMITADOR}           { return emitir(TOK_DELIMITADOR, "DELIMITADOR", yytext); }

"#"                     { return erro_lexico("marcador de comentario invalido", yytext); }
","                     { return erro_lexico("virgula fora de literal real", yytext); }
.                       { return erro_lexico("caractere nao pertence a MiniLang", yytext); }

%%

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "Uso: %s arquivo.d\n", argv[0]);
        return EXIT_FAILURE;
    }

    const char *extensao = strrchr(argv[1], '.');
    if (!extensao || strcmp(extensao, ".d") != 0) {
        fprintf(stderr, "Erro: informe um arquivo .d\n");
        return EXIT_FAILURE;
    }

    yyin = fopen(argv[1], "rb");
    if (!yyin) { perror("Erro ao abrir arquivo"); return EXIT_FAILURE; }

    puts("=== ANALISADOR LEXICO DA MINILANG ===");
    int token;
    size_t quantidade = 0;
    while ((token = yylex()) != 0) quantidade++;

    printf("Total de tokens/eventos: %zu | Erros: %d\n", quantidade, erros);

    fclose(yyin);
    free(buffer_lexema);
    return erros ? EXIT_FAILURE : EXIT_SUCCESS;
}
