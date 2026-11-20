#!/bin/bash
# ==============================================================================
# Script: 04_metodo3.sh
# Trabalho Prático 1 - Sistemas Operativos (Sistema Eugénio)
# Objetivo: Gerar abreviaturas com ESTRATÉGIA LIVRE (Método MCSF - Codificação por
#           Saliência Consonantal Ponderada por Frequência).
# Ficheiro gerado: results/abreviaturas_metodo3.txt
# Formato: <abreviatura><TAB><palavra_original>
# ==============================================================================

set -euo pipefail

TREINO_FILE="${1:-data/treino.txt}"
OUTPUT_DIR="results"
OUTPUT_FILE="${OUTPUT_DIR}/abreviaturas_metodo3.txt"

mkdir -p "$OUTPUT_DIR"

if [ ! -f "$TREINO_FILE" ]; then
    echo "ERRO: Ficheiro de treino '$TREINO_FILE' não encontrado!" >&2
    exit 1
fi

echo "=========================================================="
echo "    Abordagem 3: Estratégia Livre (Método MCSF)"
echo "    Codificação por Saliência Consonantal e Frequência"
echo "=========================================================="
echo "Ficheiro de Treino : $TREINO_FILE"
echo "Ficheiro de Saída  : $OUTPUT_FILE"

# Fundamentação Teórica da Abordagem 3:
# Baseada em princípios de Ergonomia Cognitiva e Comunicação Aumentativa (CAA):
# 1. Âncora Cognitiva: A primeira letra da palavra é sempre preservada (gatilho mnemónico).
# 2. Filtro de Relevância: Palavras muito curtas (comprimento < 4) não são abreviadas,
#    evitando sobrecarga de memorização e saturação do espaço de códigos.
# 3. Saliência Fonética: Utilização das consoantes chave subsequentes da palavra.
# 4. Desambiguação por Frequência: As palavras mais frequentes no corpus de treino
#    têm prioridade para obter as abreviaturas mais curtas (2 carateres). Em caso de
#    conflito, a palavra menos frequente expande para 3 carateres distintivos.

awk '
{
    linha = tolower($0)
    gsub(/[.,;:!?()«»"'\''_—\-\/\\]/, " ", linha)
    n = split(linha, palavras, " ")
    for (i = 1; i <= n; i++) {
        p = palavras[i]
        if (p ~ /^[a-záàâãéêíóôõúç]+$/) {
            freq[p]++
        }
    }
}

END {
    # Ordenar palavras por frequência decrescente
    total_palavras = 0
    for (p in freq) {
        # Apenas palavras com pelo menos 4 letras são candidatas à abreviação
        if (length(p) >= 4) {
            lista[++total_palavras] = p
        }
    }

    # Ordenação simples (Bubble Sort das palavras candidatas por frequência decrescente)
    for (i = 1; i <= total_palavras; i++) {
        for (j = i + 1; j <= total_palavras; j++) {
            if (freq[lista[j]] > freq[lista[i]]) {
                tmp = lista[i]
                lista[i] = lista[j]
                lista[j] = tmp
            }
        }
    }

    # Atribuição de abreviaturas inequívocas
    for (i = 1; i <= total_palavras; i++) {
        p = lista[i]
        len = length(p)
        primeira_letra = substr(p, 1, 1)
        resto = substr(p, 2)
        
        # Extrair todas as consoantes do resto da palavra
        consoantes = resto
        gsub(/[aeiouáàâãéêíóôõú]/, "", consoantes)
        n_cons = length(consoantes)
        
        abrev_escolhida = ""
        
        # Nível 1: Primeira letra + 1ª consoante subsequente (2 letras)
        if (n_cons >= 1) {
            c1 = primeira_letra substr(consoantes, 1, 1)
            if (!(c1 in mapa_ocupado) && length(c1) < len) {
                abrev_escolhida = c1
            }
        }
        
        # Nível 2: Primeira letra + 1ª e 2ª consoantes subsequentes (3 letras)
        if (abrev_escolhida == "" && n_cons >= 2) {
            c2 = primeira_letra substr(consoantes, 1, 2)
            if (!(c2 in mapa_ocupado) && length(c2) < len) {
                abrev_escolhida = c2
            }
        }
        
        # Nível 3: Primeira letra + 1ª consoante + última letra da palavra (3 letras)
        if (abrev_escolhida == "" && n_cons >= 1) {
            c3 = primeira_letra substr(consoantes, 1, 1) substr(p, len, 1)
            if (!(c3 in mapa_ocupado) && length(c3) < len) {
                abrev_escolhida = c3
            }
        }
        
        # Nível 4: Prefixo mínimo de 3 ou 4 letras se ainda não atribuído
        if (abrev_escolhida == "") {
            for (L = 3; L <= 4 && L < len; L++) {
                pref = substr(p, 1, L)
                if (!(pref in mapa_ocupado)) {
                    abrev_escolhida = pref
                    break
                }
            }
        }
        
        # Se encontramos uma abreviatura única e válida:
        if (abrev_escolhida != "") {
            mapa_ocupado[abrev_escolhida] = p
            resultado[abrev_escolhida] = p
        }
    }

    # Imprimir no formato padrão
    for (abrev in resultado) {
        print abrev "\t" resultado[abrev]
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
