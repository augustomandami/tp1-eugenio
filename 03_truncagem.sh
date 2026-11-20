#!/bin/bash
# ==============================================================================
# Script: 03_truncagem.sh
# Trabalho Prático 1 - Sistemas Operativos (Sistema Eugénio)
# Objetivo: Gerar abreviaturas baseadas na técnica da TRUNCAGEM (prefixos mínimos únicos).
# Ficheiro gerado: results/abreviaturas_truncagem.txt
# Formato: <abreviatura><TAB><palavra_original>
# ==============================================================================

set -euo pipefail

TREINO_FILE="${1:-data/treino.txt}"
OUTPUT_DIR="results"
OUTPUT_FILE="${OUTPUT_DIR}/abreviaturas_truncagem.txt"

mkdir -p "$OUTPUT_DIR"

if [ ! -f "$TREINO_FILE" ]; then
    echo "ERRO: Ficheiro de treino '$TREINO_FILE' não encontrado!" >&2
    exit 1
fi

echo "=========================================================="
echo "    Abordagem 2: Geração por Truncagem (Prefixos Mínimos)"
echo "=========================================================="
echo "Ficheiro de Treino : $TREINO_FILE"
echo "Ficheiro de Saída  : $OUTPUT_FILE"

# Processamento com AWK:
# 1. Extrair vocabulário único em minúsculas (sem pontuação).
# 2. Algoritmo do Prefixo Único Mais Curto (Shortest Unique Prefix):
#    - Para cada palavra w:
#      - Testar prefixos de comprimento L = 1 até length(w) - 1.
#      - Contar quantas palavras do vocabulário partilham esse mesmo prefixo.
#      - O primeiro comprimento L cujo prefixo seja exclusivo de w torna-se a sua abreviatura.
#    - Se nenhum prefixo próprio for exclusivo (colisão inevitável com palavras mais longas),
#      a palavra não é abreviada por truncagem, garantindo distinção absoluta.
# 3. Gravar resultados ordenados por abreviatura.

awk '
{
    linha = tolower($0)
    gsub(/[.,;:!?()«»"'\''_—\-\/\\]/, " ", linha)
    n = split(linha, palavras, " ")
    for (i = 1; i <= n; i++) {
        p = palavras[i]
        if (p ~ /^[a-záàâãéêíóôõúç]+$/) {
            vocab[p] = 1
        }
    }
}

END {
    # Converter chaves do vocabulário num vetor indexado
    total_vocab = 0
    for (p in vocab) {
        lista[++total_vocab] = p
    }

    # Pré-computar a contagem de cada prefixo em todo o vocabulário
    for (i = 1; i <= total_vocab; i++) {
        p = lista[i]
        len = length(p)
        for (L = 1; L < len; L++) {
            pref = substr(p, 1, L)
            prefix_count[pref]++
        }
    }

    # Determinar para cada palavra o menor prefixo exclusivo (prefix_count == 1)
    # Exigir comprimento mínimo de 2 carateres para evitar abreviaturas de 1 letra,
    # que são cognitivamente pouco naturais, mas permitindo se L >= 2 e L < len
    total_abrevs = 0
    for (i = 1; i <= total_vocab; i++) {
        p = lista[i]
        len = length(p)
        encontrou = 0
        
        # Testar a partir de L = 2 (ou L = 1 para palavras de 3 letras se for exclusivo)
        min_L = (len >= 3) ? 2 : 1
        for (L = min_L; L < len; L++) {
            pref = substr(p, 1, L)
            if (prefix_count[pref] == 1) {
                abrev_resultado[pref] = p
                encontrou = 1
                total_abrevs++
                break
            }
        }
    }

    # Imprimir no formato de duas colunas separadas por tabulação
    for (abrev in abrev_resultado) {
        print abrev "\t" abrev_resultado[abrev]
    }
}
' "$TREINO_FILE" | sort -k1,1 > "$OUTPUT_FILE"

TOTAL_GERADAS=$(wc -l < "$OUTPUT_FILE")

echo "----------------------------------------------------------"
echo "Total de abreviaturas geradas: $TOTAL_GERADAS"
echo "Ficheiro gravado em: $OUTPUT_FILE"
echo "Amostra das primeiras 5 abreviaturas:"
head -n 5 "$OUTPUT_FILE"
echo "=========================================================="
