# Compiladores - Parte 1: lexer TypeScript
# Somente GNU Make + comandos de shell (sem Python e sem scripts externos).
# make | make run ARQUIVO=testes/validos/01_smoke_geral.ts
# make test | make test-validos | make test-invalidos | make test-exploratorios
# make clean | make rebuild

CC := gcc
FLEX := flex
CFLAGS := -std=c11 -Wall -Wextra -D_POSIX_C_SOURCE=200809L
FONTE := typescript.l
GERADO := lex.yy.c
EXECUTAVEL := typescript
PASTA_TESTES := testes
RESULTADOS := resultados
ARQUIVO ?= testes/validos/01_smoke_geral.ts
GRUPO ?= todos

.DEFAULT_GOAL := all
.ONESHELL:
SHELL := /bin/sh

.PHONY: all run test testes test-validos test-invalidos test-exploratorios clean rebuild help

all: $(EXECUTAVEL)

$(GERADO): $(FONTE)
	$(FLEX) -o $@ $<

$(EXECUTAVEL): $(GERADO)
	$(CC) $(CFLAGS) $< -o $@

run: $(EXECUTAVEL)
	./$(EXECUTAVEL) "$(ARQUIVO)"

test-validos: $(EXECUTAVEL)
	@$(MAKE) --no-print-directory test GRUPO=validos

test-invalidos: $(EXECUTAVEL)
	@$(MAKE) --no-print-directory test GRUPO=invalidos

test-exploratorios: $(EXECUTAVEL)
	@$(MAKE) --no-print-directory test GRUPO=exploratorios

testes: test

test: $(EXECUTAVEL)
	@set -eu
	mkdir -p "$(RESULTADOS)"
	lista="$(RESULTADOS)/.lista_testes_$$$$.tmp"
	trap 'rm -f "$$lista"' EXIT HUP INT TERM
	find "$(PASTA_TESTES)" -type f -name '*.ts' | LC_ALL=C sort > "$$lista"
	if ! test -s "$$lista"; then
	  echo 'ERRO: nenhum .ts encontrado em testes/'; exit 2
	fi
	rel="$(RESULTADOS)/relatorio.md"
	csv="$(RESULTADOS)/resumo.csv"
	printf '# Relatorio de testes - Lexer TypeScript\n\n| Teste | Esperado | Obtido | Checagens | Resultado |\n|---|---|---|---:|---|\n' > "$$rel"
	printf 'grupo;teste;esperado;obtido;resultado;checagens\n' > "$$csv"
	aprovados=0; reprovados=0; exploratorios=0; total=0; ignorados=0
	while IFS= read -r arquivo; do
	  case "$$arquivo" in
	    */validos/*) grupo=validos; esperado='exit=0, Erros: 0 + tokens';;
	    */invalidos/*) grupo=invalidos; esperado='exit!=0 + ERRO_LEXICO';;
	    */exploratorios/*) grupo=exploratorios; esperado='observacional';;
	    *) echo "IGNORADO (pasta nao classificada): $$arquivo"; ignorados=$$((ignorados+1)); continue;;
	  esac
	  if [ "$(GRUPO)" != todos ] && [ "$(GRUPO)" != "$$grupo" ]; then continue; fi
	  total=$$((total+1))
	  nome=$${arquivo##*/}
	  pasta="$(RESULTADOS)/$$grupo"
	  mkdir -p "$$pasta"
	  stdout="$$pasta/$${nome%.ts}.stdout.txt"
	  stderr="$$pasta/$${nome%.ts}.stderr.txt"
	  checagem="$$pasta/$${nome%.ts}.checagens.txt"
	  rm -f "$$checagem"
	  if ./$(EXECUTAVEL) "$$arquivo" > "$$stdout" 2> "$$stderr"; then codigo=0; else codigo=$$?; fi
	  erros_relato='(sem resumo)'
	  if grep -Eq 'Erros:[[:space:]]*[0-9]+' "$$stdout"; then
	    erros_relato=$$(sed -n 's/.*Erros:[[:space:]]*\([0-9][0-9]*\).*/\1/p' "$$stdout" | tail -n 1)
	  fi
	  obtido="exit=$$codigo, Erros=$$erros_relato"
	  falhas=0; verificacoes=0; resultado=APROVADO
	  if [ "$$grupo" = validos ]; then
	    if [ "$$codigo" -ne 0 ] || [ "$$erros_relato" != 0 ] || grep -q 'ERRO_LEXICO' "$$stderr"; then
	      falhas=$$((falhas+1))
	      echo '  Divergencia: esperado exit=0 e Erros: 0' >> "$$pasta/$${nome%.ts}.checagens.txt"
	    fi
	  elif [ "$$grupo" = invalidos ]; then
	    if [ "$$codigo" -eq 0 ] || ! grep -q 'ERRO_LEXICO' "$$stderr"; then
	      falhas=$$((falhas+1))
	      echo '  Divergencia: esperado exit!=0 e ERRO_LEXICO no stderr' >> "$$pasta/$${nome%.ts}.checagens.txt"
	    fi
	  else
	    resultado=EXPLORATORIO
	  fi
	  if [ "$$grupo" != exploratorios ]; then
	    # Lista de tokens esperados no proprio Makefile.
	    set --
	    case "$$nome" in
	  01_smoke_geral.ts) set -- 'HASHBANG@@#!/usr/bin/env node' 'COMENTARIO_LINHA@@// Comentario TypeScript' KEYWORD@@const 'STRING@@"Ana\nMaria"' NUMBER@@0xFF BIGINT@@12345678901234567890n 'TEMPLATE_ABRE@@`' 'INTERPOLACAO_ABRE@@$${' 'IDENTIFICADOR_PRIVADO@@#saldo' 'LOGICO@@&&' ;;
	  02_palavras_reservadas.ts) set -- KEYWORD@@break KEYWORD@@class KEYWORD@@instanceof KEYWORD@@while ;;
	  03_reservadas_restritas.ts) set -- RESERVADA_RESTRITA@@implements RESERVADA_RESTRITA@@let RESERVADA_RESTRITA@@yield ;;
	  04_contextuais.ts) set -- CONTEXTUAL@@abstract CONTEXTUAL@@accessor CONTEXTUAL@@string CONTEXTUAL@@using ;;
	  05_literais_palavra.ts) set -- LITERAL@@true LITERAL@@false LITERAL@@null ;;
	  06_identificadores_ascii.ts) set -- IDENTIFICADOR@@a IDENTIFICADOR@@_ 'IDENTIFICADOR@@$$' 'IDENTIFICADOR@@$$abc_123' ;;
	  07_maior_correspondencia.ts) set -- IDENTIFICADOR@@constante IDENTIFICADOR@@ifelse IDENTIFICADOR@@interfaceX IDENTIFICADOR@@assertsExtra ;;
	  08_inteiros_decimais.ts) set -- NUMBER@@0 NUMBER@@1 NUMBER@@42 NUMBER@@987654321 ;;
	  09_decimais_fracionarios.ts) set -- NUMBER@@3.14 NUMBER@@.75 NUMBER@@10. NUMBER@@0.125 ;;
	  10_notacao_cientifica.ts) set -- NUMBER@@1e10 NUMBER@@2.5e-3 NUMBER@@.5E+2 NUMBER@@10.e4 ;;
	  11_separadores_decimais.ts) set -- NUMBER@@1_000 NUMBER@@10_000_000 NUMBER@@3.1_4 NUMBER@@.1_2 ;;
	  12_hexadecimais.ts) set -- NUMBER@@0xFF NUMBER@@0X1a NUMBER@@0xA_B_C ;;
	  13_binarios.ts) set -- NUMBER@@0b1010 NUMBER@@0B11 NUMBER@@0b1_0_1 ;;
	  14_octais.ts) set -- NUMBER@@0o755 NUMBER@@0O17 NUMBER@@0o7_5 ;;
	  15_bigints.ts) set -- BIGINT@@12345678901234567890n BIGINT@@0xFFn BIGINT@@0b1010n BIGINT@@0o77n BIGINT@@1_000n ;;
	  16_sinais_unarios_binarios.ts) set -- NUMBER@@10 ARITMETICO@@- INCREMENTO@@-- ARITMETICO@@+ ;;
	  17_aritmeticos.ts) set -- ARITMETICO@@+ ARITMETICO@@- 'ARITMETICO@@*' ARITMETICO@@/ ARITMETICO@@% 'ARITMETICO@@**' ;;
	  18_incremento_decremento.ts) set -- INCREMENTO@@++ INCREMENTO@@-- ;;
	  19_relacionais.ts) set -- 'RELACIONAL@@<' 'RELACIONAL@@>' 'RELACIONAL@@<=' 'RELACIONAL@@>=' ;;
	  20_igualdade.ts) set -- IGUALDADE@@== 'IGUALDADE@@!=' IGUALDADE@@=== 'IGUALDADE@@!==' ;;
	  21_logicos.ts) set -- 'LOGICO@@&&' 'LOGICO@@||' 'LOGICO@@!' 'LOGICO@@??' ;;
	  22_bitwise.ts) set -- 'BITWISE@@&' 'BITWISE@@|' 'BITWISE@@^' 'BITWISE@@~' ;;
	  23_deslocamento.ts) set -- 'DESLOCAMENTO@@<<' 'DESLOCAMENTO@@>>' 'DESLOCAMENTO@@>>>' ;;
	  24_atribuicoes_compostas.ts) set -- ATRIBUICAO@@= ATRIBUICAO@@+= 'ATRIBUICAO@@**=' 'ATRIBUICAO@@>>>=' 'ATRIBUICAO@@&&=' 'ATRIBUICAO@@||=' 'ATRIBUICAO@@??=' ;;
	  25_ternario_e_acesso.ts) set -- 'CONDICIONAL@@?' CONDICIONAL@@: ACESSO@@. 'ACESSO@@?.' NUMBER@@.5 ;;
	  26_spread_seta_decorador.ts) set -- 'SETA@@=>' SPREAD@@... DECORADOR@@@ 'DELIMITADOR@@{' ;;
	  27_delimitadores.ts) set -- 'DELIMITADOR@@(' 'DELIMITADOR@@)' 'DELIMITADOR@@{' 'DELIMITADOR@@}' 'DELIMITADOR@@[' 'DELIMITADOR@@]' DELIMITADOR@@, 'PONTO_VIRGULA@@;' ;;
	  28_string_aspas_duplas.ts) set -- 'STRING@@"Ana"' 'STRING@@"Linha\nseguinte"' 'STRING@@"Ele disse: \"oi\""' ;;
	  29_string_aspas_simples.ts) set -- 'STRING@@'"'"'ola'"'"'' 'STRING@@'"'"'it\'"'"'s fine'"'"'' ;;
	  30_string_continuacao_linha.ts) set -- 'STRING@@"linha 1\' KEYWORD@@const ;;
	  31_comentarios_linha.ts) set -- 'COMENTARIO_LINHA@@// primeira linha' 'COMENTARIO_LINHA@@// segunda linha' ;;
	  32_comentarios_bloco.ts) set -- 'COMENTARIO_BLOCO@@/* inicio' KEYWORD@@const ;;
	  33_comentarios_asteriscos.ts) set -- 'COMENTARIO_BLOCO@@/* a ** b / c' KEYWORD@@const ;;
	  34_hashbang_inicio.ts) set -- 'HASHBANG@@#!/usr/bin/env node' KEYWORD@@const ;;
	  35_template_simples.ts) set -- 'TEMPLATE_ABRE@@`' 'TEMPLATE_TEXTO@@Ola mundo' 'TEMPLATE_FECHA@@`' ;;
	  36_template_interpolacao.ts) set -- 'INTERPOLACAO_ABRE@@$${' IDENTIFICADOR@@nome 'INTERPOLACAO_FECHA@@}' ;;
	  37_template_multiplas_interpolacoes.ts) set -- 'INTERPOLACAO_ABRE@@$${' ARITMETICO@@+ 'TEMPLATE_FECHA@@`' ;;
	  38_template_objeto_em_interpolacao.ts) set -- 'INTERPOLACAO_ABRE@@$${' 'DELIMITADOR@@{' 'DELIMITADOR@@}' 'INTERPOLACAO_FECHA@@}' ;;
	  39_identificador_privado.ts) set -- 'IDENTIFICADOR_PRIVADO@@#saldo' ACESSO@@. KEYWORD@@class ;;
	  40_objeto_interface_tipos.ts) set -- RESERVADA_RESTRITA@@interface CONTEXTUAL@@string CONTEXTUAL@@number CONDICIONAL@@: ;;
	  41_comentario_em_string.ts) set -- 'STRING@@"https://example.com/a//b"' 'STRING@@"/* nao comentar */"' ;;
	  42_prioridade_operadores.ts) set -- 'ATRIBUICAO@@>>>=' 'IGUALDADE@@!==' 'ARITMETICO@@**' 'ACESSO@@?.' ;;
	  43_espacos_e_quebras.ts) set -- KEYWORD@@const RESERVADA_RESTRITA@@let NUMBER@@2 ;;
	      *) : ;;
	    esac
	    for par do
	      categoria=$${par%%@@*}
	      lexema=$${par#*@@}
	      verificacoes=$$((verificacoes+1))
	      if ! EXPECT_CAT="$$categoria" EXPECT_LEX="$$lexema" awk '
	        /^linha[[:space:]]+[0-9]+[[:space:]]*\|/ {
	          atual=$$0
	          sub(/^[^|]*\|[[:space:]]*/, "", atual)
	          classe=atual
	          sub(/[[:space:]]*\|.*/, "", classe)
	          sub(/^[^|]*\|[[:space:]]*/, "", atual)
	          esperado=ENVIRON["EXPECT_LEX"]
	          if (classe==ENVIRON["EXPECT_CAT"] && substr(atual,1,length(esperado))==esperado) {
	            sufixo=substr(atual,length(esperado)+1,1)
	            if (sufixo=="" || sufixo ~ /[[:space:]]/) {achou=1; exit}
	          }
	        }
	        END {exit !achou}
	      ' "$$stdout"; then
	        printf '  AUSENTE: %s -> %s\n' "$$categoria" "$$lexema" >> "$$checagem"
	        falhas=$$((falhas+1))
	      fi
	    done
	    # Tokens que nao podem aparecer como categorias especificadas.
	    set --
	    case "$$nome" in
	  07_maior_correspondencia.ts) set -- KEYWORD@@constante KEYWORD@@ifelse ;;
	  16_sinais_unarios_binarios.ts) set -- NUMBER@@-5 ;;
	  41_comentario_em_string.ts) set -- COMENTARIO_LINHA@@//b 'COMENTARIO_BLOCO@@/* nao comentar */' ;;
	      *) : ;;
	    esac
	    for par do
	      categoria=$${par%%@@*}
	      lexema=$${par#*@@}
	      verificacoes=$$((verificacoes+1))
	      if EXPECT_CAT="$$categoria" EXPECT_LEX="$$lexema" awk '
	        /^linha[[:space:]]+[0-9]+[[:space:]]*\|/ {
	          atual=$$0
	          sub(/^[^|]*\|[[:space:]]*/, "", atual)
	          classe=atual
	          sub(/[[:space:]]*\|.*/, "", classe)
	          sub(/^[^|]*\|[[:space:]]*/, "", atual)
	          esperado=ENVIRON["EXPECT_LEX"]
	          if (classe==ENVIRON["EXPECT_CAT"] && substr(atual,1,length(esperado))==esperado) {
	            sufixo=substr(atual,length(esperado)+1,1)
	            if (sufixo=="" || sufixo ~ /[[:space:]]/) {achou=1; exit}
	          }
	        }
	        END {exit !achou}
	      ' "$$stdout"; then
	        printf '  INDEVIDO: %s -> %s\n' "$$categoria" "$$lexema" >> "$$checagem"
	        falhas=$$((falhas+1))
	      fi
	    done
	    if [ "$$falhas" -gt 0 ]; then resultado=FALHOU; fi
	  fi
	  if [ "$$resultado" = APROVADO ]; then aprovados=$$((aprovados+1)); fi
	  if [ "$$resultado" = FALHOU ]; then reprovados=$$((reprovados+1)); fi
	  if [ "$$resultado" = EXPLORATORIO ]; then exploratorios=$$((exploratorios+1)); fi
	  printf '[%-12s] %-56s esperado: %-28s obtido: %s (checagens=%s)\n' "$$resultado" "$$nome" "$$esperado" "$$obtido" "$$verificacoes"
	  if [ "$$resultado" = FALHOU ]; then
	    if test -f "$$checagem"; then cat "$$checagem"; fi
	  else
	    rm -f "$$checagem"
	  fi
	  printf '| `%s` | %s | %s | %s | **%s** |\n' "$$arquivo" "$$esperado" "$$obtido" "$$verificacoes" "$$resultado" >> "$$rel"
	  printf '%s;%s;%s;%s;%s;%s\n' "$$grupo" "$$nome" "$$esperado" "$$obtido" "$$resultado" "$$verificacoes" >> "$$csv"
	done < "$$lista"
	printf '\nRESULTADO FINAL: %s testes | %s aprovados | %s reprovados | %s exploratorios | %s ignorados\n' "$$total" "$$aprovados" "$$reprovados" "$$exploratorios" "$$ignorados"
	printf 'Saidas: $(RESULTADOS)/{validos,invalidos,exploratorios}/\nRelatorio: %s\n' "$$rel"
	printf '\n**Total:** %s | **Aprovados:** %s | **Reprovados:** %s | **Exploratorios:** %s\n' "$$total" "$$aprovados" "$$reprovados" "$$exploratorios" >> "$$rel"
	if [ "$$reprovados" -gt 0 ]; then exit 1; fi

clean:
	rm -f $(GERADO) $(EXECUTAVEL)

rebuild:
	$(MAKE) clean
	$(MAKE) all

help:
	@echo 'make           : compilar o lexer'
	@echo 'make test      : todos os arquivos .ts em testes/{validos,invalidos,exploratorios}'
	@echo 'make test-validos / make test-invalidos / make test-exploratorios'
	@echo 'make run ARQUIVO=testes/validos/01_smoke_geral.ts'
	@echo 'make clean | make rebuild'
