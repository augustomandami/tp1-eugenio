#!/bin/bash
# ==============================================================================
# Script: 02_contracao.sh
# Trabalho Prático 1 - Sistemas Operativos (Sistema Eugénio)
# Objetivo: Gerar abreviaturas baseadas na técnica da CONTRAÇÃO (remoção de vogais).
# Ficheiro gerado: results/abreviaturas_contracao.txt
# Formato: <abreviatura><TAB><palavra_original>
# ==============================================================================

set -euo pipefail

TREINO_FILE="${1:-data/treino.txt}"
OUTPUT_DIR="results"
OUTPUT_FILE="${OUTPUT_DIR}/abreviaturas_contracao.txt"

mkdir -p "$OUTPUT_DIR"

if [ ! -f "$TREINO_FILE" ]; then
    echo "ERRO: Ficheiro de treino '$TREINO_FILE' não encontrado!" >&2
    exit 1
fi

echo "=========================================================="
echo "    Abordagem 1: Geração por Contração (Remoção de Vogais)"
echo "=========================================================="
echo "Ficheiro de Treino : $TREINO_FILE"
echo "Ficheiro de Saída  : $OUTPUT_FILE"

# Processamento com AWK:
# 1. Normalização do texto (minúsculas, remoção de pontuação).
# 2. Contagem de frequência de cada palavra no conjunto de treino.
# 3. Para cada palavra única:
#    - Remover todas as vogais (a, e, i, o, u, á, à, â, ã, é, ê, í, ó, ô, õ, ú).
#    - Descartar se o resultado for vazio ou se o tamanho da abreviatura for igual ao original.
# 4. Resolução determinística de colisões:
#    - Se duas palavras produzirem a mesma contração, atribui-se à palavra com maior frequência.
# 5. Ordenação alfabética da saída para facilidade de consulta.

awk '
BEGIN {
    # Lista de vogais em minúsculas (incluindo acentuadas)
    vogais = "[aeiouáàâãéêíóôõú]"
}

# Leitura e tokenização linha a linha
{
    # Converter para minúsculas
    linha = tolower($0)
    
    # Substituir pontuação e carateres especiais por espaços
    gsub(/[.,;:!?()«»"'\''_—\-\/\\]/, " ", linha)
    
    n = split(linha, palavras, " ")
    for (i = 1; i <= n; i++) {
        p = palavras[i]
        # Manter apenas tokens alfabéticos com pelo menos 1 caráter
        if (p ~ /^[a-záàâãéêíóôõúç]+$/) {
            freq[p]++
        }
    }
}

END {
    # Para cada palavra única, calcular a contração
    for (p in freq) {
        # Remover vogais
        abrev = p
        gsub(/[aeiouáàâãéêíóôõú]/, "", abrev)
        
        # Só é válida se a contração não for vazia e for mais curta que a palavra original
        if (length(abrev) > 0 && length(abrev) < length(p)) {
            # Se a abreviatura ainda não foi atribuída, ou se esta palavra tem maior frequência:
            if (!(abrev in mapa) || freq[p] > freq_mapa[abrev]) {
                if (abrev in mapa) {
                    colisoes++
                }
                mapa[abrev] = p
                freq_mapa[abrev] = freq[p]
            } else {
                colisoes++
            }
        } else {
            descartadas++
        }
    }
    
    # Imprimir resultado no formato tabulado exigido
    for (abrev in mapa) {
        print abrev "\t" mapa[abrev]
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
