#!/bin/bash
# ==============================================================================
# Script: run_all.sh
# Trabalho Prático 1 - Sistemas Operativos (Sistema Eugénio)
# Objetivo: Executar todo o pipeline do projeto de forma sequencial e integrada:
#           1. Divisão do corpus (80% treino / 20% teste)
#           2. Geração de abreviaturas por Contração
#           3. Geração de abreviaturas por Truncagem
#           4. Geração de abreviaturas pelo Método 3 (MCSF)
#           5. Simulação da escrita e cálculo de métricas comparativas
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$ROOT_DIR"

echo "======================================================================"
echo "   INICIANDO EXECUÇÃO COMPLETA: SISTEMA DE ABREVIATURAS EUGÉNIO"
echo "======================================================================"

CORPUS_PATH="${1:-data/corpus.txt}"

if [ ! -f "$CORPUS_PATH" ]; then
    if [ -f "data/corpus_exemplo.txt" ]; then
        echo "Aviso: '$CORPUS_PATH' não encontrado. A utilizar 'data/corpus_exemplo.txt' como corpus inicial."
        cp "data/corpus_exemplo.txt" "data/corpus.txt"
        CORPUS_PATH="data/corpus.txt"
    else
        echo "ERRO: Nenhum corpus encontrado em 'data/'!" >&2
        exit 1
    fi
fi

# Passo 1: Divisão dos dados
echo ""
echo ">>> [PASSO 1/5] Divisão dos dados (80% treino / 20% teste)..."
bash scripts/01_separacao_dados.sh "$CORPUS_PATH" 42

# Passo 2: Contração
echo ""
echo ">>> [PASSO 2/5] Geração por Contração..."
bash scripts/02_contracao.sh data/treino.txt

# Passo 3: Truncagem
echo ""
echo ">>> [PASSO 3/5] Geração por Truncagem..."
bash scripts/03_truncagem.sh data/treino.txt

# Passo 4: Método 3
echo ""
echo ">>> [PASSO 4/5] Geração pelo Método 3 (Estratégia Livre)..."
bash scripts/04_metodo3.sh data/treino.txt

# Passo 5: Simulação da escrita
echo ""
echo ">>> [PASSO 5/5] Simulação de escrita e avaliação de desempenho..."
bash scripts/05_simula_escrita.sh data/teste.txt all

echo ""
echo "======================================================================"
echo "   PIPELINE CONCLUÍDO COM SUCESSO!"
echo "   Consulte os dicionários e métricas na diretoria 'results/'"
echo "======================================================================"
