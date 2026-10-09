SHELL := /bin/bash
.SHELLFLAGS := -e -o pipefail -c

FLEX       := flex
CC         := gcc
CFLAGS     := -std=c11 -O2 -Wall -Wextra -D_POSIX_C_SOURCE=200809L
LEXER      := minilang.l
GERADO     := lex.yy.c
EXECUTAVEL := minilang
TESTES     := testes
ESPERADO   := esperado
RESULTADOS := resultados

ARQUIVO ?= testes/programas/programa_1_cadastro_salario.d

.PHONY: all run test test-programas test-adicionais clean rebuild ajuda

all: $(EXECUTAVEL)

$(GERADO): $(LEXER)
	$(FLEX) -o $@ $<

$(EXECUTAVEL): $(GERADO)
	$(CC) $(CFLAGS) $< -o $@

run: $(EXECUTAVEL)
	./$(EXECUTAVEL) "$(ARQUIVO)"

test: $(EXECUTAVEL)
	@$(MAKE) --no-print-directory _verificar GRUPO=programas
	@$(MAKE) --no-print-directory _verificar GRUPO=adicionais
	@echo; echo 'Todos os testes obrigatorios e adicionais passaram.'

test-programas: $(EXECUTAVEL)
	@$(MAKE) --no-print-directory _verificar GRUPO=programas

test-adicionais: $(EXECUTAVEL)
	@$(MAKE) --no-print-directory _verificar GRUPO=adicionais

.PHONY: _verificar
_verificar: $(EXECUTAVEL)
	@mkdir -p "$(RESULTADOS)/$(GRUPO)"; \
	aprovados=0; reprovados=0; total=0; \
	while IFS= read -r -d '' arquivo; do \
	  nome="$${arquivo##*/}"; nome="$${nome%.d}"; \
	  saida="$(RESULTADOS)/$(GRUPO)/$$nome.txt"; \
	  referencia="$(ESPERADO)/$(GRUPO)/$$nome.txt"; \
	  esperado_exit="$(ESPERADO)/$(GRUPO)/$$nome.exit"; \
	  status=0; ./$(EXECUTAVEL) "$$arquivo" > "$$saida" 2>&1 || status=$$?; \
	  total=$$((total + 1)); \
	  if [[ ! -f "$$referencia" || ! -f "$$esperado_exit" ]]; then \
	    echo "[SEM_REFERENCIA] $$nome"; reprovados=$$((reprovados+1)); \
	    continue; \
	  fi; \
	  read -r esperado < "$$esperado_exit"; \
	  if [[ "$$status" == "$$esperado" ]] && diff -u "$$referencia" "$$saida" > "$(RESULTADOS)/$(GRUPO)/$$nome.diff"; then \
	    echo "[APROVADO] $$nome | exit esperado=$$esperado obtido=$$status | saida identica"; \
	    aprovados=$$((aprovados+1)); \
	    rm -f "$(RESULTADOS)/$(GRUPO)/$$nome.diff"; \
	  else \
	    echo "[FALHOU] $$nome | exit esperado=$$esperado obtido=$$status"; \
	    diff -u "$$referencia" "$$saida" | head -60 || true; \
	    reprovados=$$((reprovados+1)); \
	  fi; \
	done < <(find "$(TESTES)/$(GRUPO)" -type f -name '*.d' -print0 | sort -z); \
	echo; printf 'RESUMO %-10s | %d testes | %d aprovados | %d reprovados\n' "$(GRUPO)" "$$total" "$$aprovados" "$$reprovados"; \
	[[ $$total -gt 0 && $$reprovados -eq 0 ]]

rebuild: clean all

clean:
	rm -f "$(GERADO)" "$(EXECUTAVEL)"
	rm -rf "$(RESULTADOS)"

ajuda:
	@echo 'make                   - Compila Flex e GCC'
	@echo 'make test              - Verifica os 5 programas e os 14 adicionais'
	@echo 'make test-programas    - Apenas os programas do PDF'
	@echo 'make test-adicionais   - Apenas os testes extras'
	@echo 'make run ARQUIVO=...   - Executa um arquivo .d especifico'
	@echo 'make rebuild           - Limpa e recompila'
	@echo 'make clean             - Remove gerados e resultados'
