# Relatorio de testes - Lexer TypeScript

| Teste | Esperado | Obtido | Checagens | Resultado |
|---|---|---|---:|---|
| `testes/exploratorios/64_identificador_unicode.ts` | observacional | exit=1, Erros=4 | 0 | **EXPLORATORIO** |
| `testes/exploratorios/65_identificador_escape_unicode.ts` | observacional | exit=1, Erros=1 | 0 | **EXPLORATORIO** |
| `testes/exploratorios/66_literal_regex.ts` | observacional | exit=0, Erros=0 | 0 | **EXPLORATORIO** |
| `testes/exploratorios/67_template_aninhado.ts` | observacional | exit=0, Erros=0 | 0 | **EXPLORATORIO** |
| `testes/exploratorios/68_jsx_tsx.ts` | observacional | exit=0, Erros=0 | 0 | **EXPLORATORIO** |
| `testes/exploratorios/69_unicode_espacamento.ts` | observacional | exit=1, Erros=2 | 0 | **EXPLORATORIO** |
| `testes/exploratorios/70_erro_separador_hexadecimal.ts` | observacional | exit=1, Erros=1 | 0 | **EXPLORATORIO** |
| `testes/exploratorios/71_zero_inicial.ts` | observacional | exit=1, Erros=1 | 0 | **EXPLORATORIO** |
| `testes/exploratorios/72_numero_seguido_identificador.ts` | observacional | exit=1, Erros=1 | 0 | **EXPLORATORIO** |
| `testes/invalidos/44_separador_duplo.ts` | exit!=0 + ERRO_LEXICO | exit=1, Erros=1 | 0 | **APROVADO** |
| `testes/invalidos/45_separador_final.ts` | exit!=0 + ERRO_LEXICO | exit=1, Erros=1 | 0 | **APROVADO** |
| `testes/invalidos/46_separador_apos_ponto.ts` | exit!=0 + ERRO_LEXICO | exit=1, Erros=1 | 0 | **APROVADO** |
| `testes/invalidos/47_binario_digito_invalido.ts` | exit!=0 + ERRO_LEXICO | exit=1, Erros=1 | 0 | **APROVADO** |
| `testes/invalidos/48_octal_digito_invalido.ts` | exit!=0 + ERRO_LEXICO | exit=1, Erros=1 | 0 | **APROVADO** |
| `testes/invalidos/49_hexadecimal_caractere_invalido.ts` | exit!=0 + ERRO_LEXICO | exit=1, Erros=1 | 0 | **APROVADO** |
| `testes/invalidos/50_hexadecimal_sem_digitos.ts` | exit!=0 + ERRO_LEXICO | exit=1, Erros=1 | 0 | **APROVADO** |
| `testes/invalidos/51_binario_sem_digitos.ts` | exit!=0 + ERRO_LEXICO | exit=1, Erros=1 | 0 | **APROVADO** |
| `testes/invalidos/52_octal_sem_digitos.ts` | exit!=0 + ERRO_LEXICO | exit=1, Erros=1 | 0 | **APROVADO** |
| `testes/invalidos/53_expoente_incompleto.ts` | exit!=0 + ERRO_LEXICO | exit=1, Erros=1 | 0 | **APROVADO** |
| `testes/invalidos/54_expoente_sinal_sem_digitos.ts` | exit!=0 + ERRO_LEXICO | exit=1, Erros=1 | 0 | **APROVADO** |
| `testes/invalidos/55_bigint_fracionario.ts` | exit!=0 + ERRO_LEXICO | exit=1, Erros=1 | 0 | **APROVADO** |
| `testes/invalidos/56_sufixo_numerico_invalido.ts` | exit!=0 + ERRO_LEXICO | exit=1, Erros=1 | 0 | **APROVADO** |
| `testes/invalidos/57_string_dupla_nao_fechada.ts` | exit!=0 + ERRO_LEXICO | exit=1, Erros=1 | 0 | **APROVADO** |
| `testes/invalidos/58_string_simples_nao_fechada.ts` | exit!=0 + ERRO_LEXICO | exit=1, Erros=1 | 0 | **APROVADO** |
| `testes/invalidos/59_comentario_bloco_nao_fechado.ts` | exit!=0 + ERRO_LEXICO | exit=1, Erros=1 | 0 | **APROVADO** |
| `testes/invalidos/60_template_nao_fechado.ts` | exit!=0 + ERRO_LEXICO | exit=1, Erros=1 | 0 | **APROVADO** |
| `testes/invalidos/61_interpolacao_nao_fechada.ts` | exit!=0 + ERRO_LEXICO | exit=1, Erros=1 | 0 | **APROVADO** |
| `testes/invalidos/62_hashbang_fora_primeira_linha.ts` | exit!=0 + ERRO_LEXICO | exit=1, Erros=1 | 0 | **APROVADO** |
| `testes/invalidos/63_caractere_desconhecido.ts` | exit!=0 + ERRO_LEXICO | exit=1, Erros=1 | 0 | **APROVADO** |
| `testes/validos/01_smoke_geral.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 10 | **APROVADO** |
| `testes/validos/02_palavras_reservadas.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 4 | **APROVADO** |
| `testes/validos/03_reservadas_restritas.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 3 | **APROVADO** |
| `testes/validos/04_contextuais.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 4 | **APROVADO** |
| `testes/validos/05_literais_palavra.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 3 | **APROVADO** |
| `testes/validos/06_identificadores_ascii.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 4 | **APROVADO** |
| `testes/validos/07_maior_correspondencia.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 6 | **APROVADO** |
| `testes/validos/08_inteiros_decimais.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 4 | **APROVADO** |
| `testes/validos/09_decimais_fracionarios.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 4 | **APROVADO** |
| `testes/validos/10_notacao_cientifica.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 4 | **APROVADO** |
| `testes/validos/11_separadores_decimais.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 4 | **APROVADO** |
| `testes/validos/12_hexadecimais.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 3 | **APROVADO** |
| `testes/validos/13_binarios.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 3 | **APROVADO** |
| `testes/validos/14_octais.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 3 | **APROVADO** |
| `testes/validos/15_bigints.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 5 | **APROVADO** |
| `testes/validos/16_sinais_unarios_binarios.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 5 | **APROVADO** |
| `testes/validos/17_aritmeticos.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 6 | **APROVADO** |
| `testes/validos/18_incremento_decremento.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 2 | **APROVADO** |
| `testes/validos/19_relacionais.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 4 | **APROVADO** |
| `testes/validos/20_igualdade.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 4 | **APROVADO** |
| `testes/validos/21_logicos.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 4 | **APROVADO** |
| `testes/validos/22_bitwise.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 4 | **APROVADO** |
| `testes/validos/23_deslocamento.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 3 | **APROVADO** |
| `testes/validos/24_atribuicoes_compostas.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 7 | **APROVADO** |
| `testes/validos/25_ternario_e_acesso.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 5 | **APROVADO** |
| `testes/validos/26_spread_seta_decorador.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 4 | **APROVADO** |
| `testes/validos/27_delimitadores.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 8 | **APROVADO** |
| `testes/validos/28_string_aspas_duplas.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 3 | **APROVADO** |
| `testes/validos/29_string_aspas_simples.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 2 | **APROVADO** |
| `testes/validos/30_string_continuacao_linha.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 2 | **APROVADO** |
| `testes/validos/31_comentarios_linha.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 2 | **APROVADO** |
| `testes/validos/32_comentarios_bloco.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 2 | **APROVADO** |
| `testes/validos/33_comentarios_asteriscos.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 2 | **APROVADO** |
| `testes/validos/34_hashbang_inicio.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 2 | **APROVADO** |
| `testes/validos/35_template_simples.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 3 | **APROVADO** |
| `testes/validos/36_template_interpolacao.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 3 | **APROVADO** |
| `testes/validos/37_template_multiplas_interpolacoes.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 3 | **APROVADO** |
| `testes/validos/38_template_objeto_em_interpolacao.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 4 | **APROVADO** |
| `testes/validos/39_identificador_privado.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 3 | **APROVADO** |
| `testes/validos/40_objeto_interface_tipos.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 4 | **APROVADO** |
| `testes/validos/41_comentario_em_string.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 4 | **APROVADO** |
| `testes/validos/42_prioridade_operadores.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 4 | **APROVADO** |
| `testes/validos/43_espacos_e_quebras.ts` | exit=0, Erros: 0 + tokens | exit=0, Erros=0 | 3 | **APROVADO** |

**Total:** 72 | **Aprovados:** 63 | **Reprovados:** 0 | **Exploratorios:** 9
