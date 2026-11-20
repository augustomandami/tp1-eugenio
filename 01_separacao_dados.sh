#!/bin/bash
# ==============================================================================
# Script: 01_separacao_dados.sh
# Trabalho Prático 1 - Sistemas Operativos (Sistema Eugénio)
# Objetivo: Realizar a divisão automática e reproduzível dos dados (80% treino, 20% teste).
# Uso: ./01_separacao_dados.sh [ficheiro_corpus] [semente_aleatoria]
# ==============================================================================

set -euo pipefail

# Parâmetros com valores padrão
CORPUS_FILE="${1:-data/corpus.txt}"
SEED="${2:-42}"
DIR_DATA="$(dirname "$CORPUS_FILE")"
TREINO_FILE="${DIR_DATA}/treino.txt"
TESTE_FILE="${DIR_DATA}/teste.txt"

echo "=========================================================="
echo "    Divisão do Corpus: 80% Treino / 20% Teste"
echo "=========================================================="
echo "Ficheiro de entrada : $CORPUS_FILE"
echo "Semente aleatória   : $SEED"

# Validação da existência do ficheiro de entrada
if [ ! -f "$CORPUS_FILE" ]; then
    echo "ERRO: O ficheiro '$CORPUS_FILE' não foi encontrado!" >&2
    exit 1
fi

# Contagem total de linhas não vazias
TOTAL_LINHAS=$(grep -cve '^\s*$' "$CORPUS_FILE" || true)

if [ "$TOTAL_LINHAS" -eq 0 ]; then
    echo "ERRO: O ficheiro '$CORPUS_FILE' está vazio!" >&2
    exit 1
fi

# Cálculo do número de linhas para treino (80%) e teste (20%)
# Usamos awk para calcular o arredondamento com precisão
LINHAS_TREINO=$(awk -v total="$TOTAL_LINHAS" 'BEGIN { printf "%d\n", (total * 0.80) + 0.5 }')
LINHAS_TESTE=$(( TOTAL_LINHAS - LINHAS_TREINO ))

echo "Total de linhas     : $TOTAL_LINHAS"
echo "Linhas para Treino  : $LINHAS_TREINO (80%)"
echo "Linhas para Teste   : $LINHAS_TESTE (20%)"

# Baralhar de forma reproduzível utilizando awk com semente fixa
# A estratégia consiste em:
# 1. Ignorar linhas vazias
# 2. Gerar número pseudo-aleatório por linha com srand(SEED)
# 3. Ordenar numericamente pela primeira coluna (sort -k1,1n)
# 4. Remover o número pseudo-aleatório com cut
# 5. Dividir em treino (head) e teste (tail)
TEMP_SHUFFLED=$(mktemp)

awk -v seed="$SEED" '
    BEGIN { srand(seed) }
    NF > 0 { print rand() "\t" $0 }
' "$CORPUS_FILE" | sort -k1,1n | cut -f2- > "$TEMP_SHUFFLED"

# Gravação dos ficheiros de treino e teste
head -n "$LINHAS_TREINO" "$TEMP_SHUFFLED" > "$TREINO_FILE"
tail -n "$LINHAS_TESTE" "$TEMP_SHUFFLED" > "$TESTE_FILE"

rm -f "$TEMP_SHUFFLED"

echo "----------------------------------------------------------"
echo "Ficheiro de Treino criado : $TREINO_FILE ($(wc -l < "$TREINO_FILE") linhas)"
echo "Ficheiro de Teste criado  : $TESTE_FILE ($(wc -l < "$TESTE_FILE") linhas)"
echo "Divisão concluída com sucesso e garantida por semente determinística."
echo "=========================================================="
