#!/bin/bash
# ==============================================================================
# Script: 05_simula_escrita.sh
# Trabalho Prático 1 - Sistemas Operativos (Sistema Eugénio)
# Objetivo: Simular a escrita de textos do ficheiro de teste utilizando um ou todos
#           os dicionários de abreviaturas e calcular as métricas exigidas.
# Uso: ./05_simula_escrita.sh [ficheiro_teste] [ficheiro_abreviaturas]
#      Se omitido o segundo parâmetro, avalia os 3 métodos comparativamente.
# ==============================================================================

set -euo pipefail

TESTE_FILE="${1:-data/teste.txt}"
ABREV_FILE="${2:-all}"
RESULTS_DIR="results"
METRICAS_CSV="${RESULTS_DIR}/metricas_comparativas.csv"
METRICAS_TXT="${RESULTS_DIR}/metricas_comparativas.txt"

mkdir -p "$RESULTS_DIR"

if [ ! -f "$TESTE_FILE" ]; then
    echo "ERRO: Ficheiro de teste '$TESTE_FILE' não encontrado!" >&2
    exit 1
fi

# Função para simular a escrita com um dicionário específico
simular_metodo() {
    local nome_metodo="$1"
    local f_abrev="$2"

    if [ ! -f "$f_abrev" ]; then
        echo "ERRO: Ficheiro de abreviaturas '$f_abrev' não encontrado!" >&2
        return 1
    fi

    awk -v metodo="$nome_metodo" -v arq_abrev="$f_abrev" '
    BEGIN {
        # 1. Carregar o dicionário invertido: palavra_original -> abreviatura
        while ((getline linha < arq_abrev) > 0) {
            split(linha, campos, "\t")
            if (length(campos[1]) > 0 && length(campos[2]) > 0) {
                # Se houver multiplicidade, preserva a primeira ou mais curta
                palavra = tolower(campos[2])
                abrev = campos[1]
                if (!(palavra in dict) || length(abrev) < length(dict[palavra])) {
                    dict[palavra] = abrev
                }
            }
        }
        close(arq_abrev)
        
        total_palavras = 0
        palavras_substituidas = 0
        caracteres_originais = 0
        caracteres_abreviados = 0
    }

    {
        # Processar linha a linha do ficheiro de teste
        # Contagem do comprimento original da linha (incluindo quebra de linha)
        linha_orig = $0
        tam_orig = length(linha_orig) + 1
        caracteres_originais += tam_orig
        
        # Tokenizar preservando a identificação das palavras
        linha_subst = linha_orig
        
        # Analisar palavras individuais na linha
        # Criar uma cópia limpa para identificar palavras
        linha_limpa = tolower(linha_orig)
        gsub(/[.,;:!?()«»"'\''_—\-\/\\]/, " ", linha_limpa)
        n = split(linha_limpa, palavras, " ")
        
        poupanca_linha = 0
        for (i = 1; i <= n; i++) {
            p = palavras[i]
            if (p ~ /^[a-záàâãéêíóôõúç]+$/) {
                total_palavras++
                if (p in dict) {
                    abrev = dict[p]
                    palavras_substituidas++
                    # Redução de carateres = tamanho da palavra original - tamanho da abreviatura
                    dif = length(p) - length(abrev)
                    if (dif > 0) {
                        poupanca_linha += dif
                    }
                }
            }
        }
        
        caracteres_abreviados += (tam_orig - poupanca_linha)
    }

    END {
        poupanca_absoluta = caracteres_originais - caracteres_abreviados
        if (caracteres_originais > 0) {
            poupanca_pct = (poupanca_absoluta / caracteres_originais) * 100.0
            cobertura_pct = (palavras_substituidas / total_palavras) * 100.0
        } else {
            poupanca_pct = 0.0
            cobertura_pct = 0.0
        }

        # Formato de saída: método;total_palavras;substituidas;cobertura;caract_orig;caract_abrev;poup_pct
        printf "%s;%d;%d;%.2f;%d;%d;%.2f\n", \
            metodo, total_palavras, palavras_substituidas, cobertura_pct, \
            caracteres_originais, caracteres_abreviados, poupanca_pct
    }
    ' "$TESTE_FILE"
}

if [ "$ABREV_FILE" != "all" ]; then
    # Avaliação de ficheiro único
    nome_base=$(basename "$ABREV_FILE" .txt)
    echo "=========================================================="
    echo "  Simulação da Escrita: $nome_base"
    echo "=========================================================="
    echo "Ficheiro de Teste        : $TESTE_FILE"
    echo "Ficheiro de Abreviaturas : $ABREV_FILE"
    
    res=$(simular_metodo "$nome_base" "$ABREV_FILE")
    IFS=';' read -r met tot subst cob orig abrev poup <<< "$res"
    
    echo "----------------------------------------------------------"
    echo "Total de palavras no teste      : $tot"
    echo "Palavras substituídas           : $subst"
    echo "Taxa de cobertura de palavras   : ${cob}%"
    echo "Número de carateres original    : $orig"
    echo "Número de carateres abreviado   : $abrev"
    echo "Poupança de carateres           : $(( orig - abrev )) carateres"
    echo "Percentagem de poupança (%)     : ${poup}%"
    echo "=========================================================="
else
    # Avaliação comparativa dos 3 métodos
    echo "=========================================================================================="
    echo "          Simulação Comparativa da Escrita - Métricas do Sistema Eugénio"
    echo "=========================================================================================="
    echo "Ficheiro de Teste: $TESTE_FILE"
    echo ""

    # Cabeçalho CSV
    echo "Metodo;Total_Palavras;Palavras_Substituidas;Taxa_Cobertura_Pct;Caracteres_Original;Caracteres_Abreviado;Poupanca_Pct" > "$METRICAS_CSV"

    res_contracao=$(simular_metodo "Contração" "${RESULTS_DIR}/abreviaturas_contracao.txt")
    res_truncagem=$(simular_metodo "Truncagem" "${RESULTS_DIR}/abreviaturas_truncagem.txt")
    res_metodo3=$(simular_metodo "Método 3 (MCSF)" "${RESULTS_DIR}/abreviaturas_metodo3.txt")

    echo "$res_contracao" >> "$METRICAS_CSV"
    echo "$res_truncagem" >> "$METRICAS_CSV"
    echo "$res_metodo3" >> "$METRICAS_CSV"

    # Apresentação formatada em tabela
    printf "%-18s | %-12s | %-14s | %-15s | %-15s | %-12s\n" \
        "Abordagem" "Substituídas" "Cobertura (%)" "Caract. Original" "Caract. Abrev." "Poupança (%)"
    echo "------------------------------------------------------------------------------------------"

    while IFS=';' read -r met tot subst cob orig abrev poup; do
        if [ "$met" != "Metodo" ]; then
            printf "%-18s | %-12s | %-14s | %-15s | %-15s | %-12s\n" \
                "$met" "$subst ($tot)" "${cob}%" "$orig" "$abrev" "${poup}%"
        fi
    done < "$METRICAS_CSV"

    echo "=========================================================================================="
    echo "Resultados gravados em:"
    echo "  - $METRICAS_CSV"
fi
