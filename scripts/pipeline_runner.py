#!/usr/bin/env python3
"""
Pipeline de Execução e Validação dos Modelos de Abreviações
Trabalho Prático 1 - Sistemas Operativos (Sistema Eugénio)

Este script implementa e valida exatamente a mesma lógica dos scripts Bash,
permitindo a execução em ambientes Windows/Linux e a geração imediata dos resultados,
dicionários e métricas para o relatório.
"""

import os
import re
import random
import csv

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(BASE_DIR, "data")
RESULTS_DIR = os.path.join(BASE_DIR, "results")
os.makedirs(RESULTS_DIR, exist_ok=True)

CORPUS_FILE = os.path.join(DATA_DIR, "corpus.txt")
TREINO_FILE = os.path.join(DATA_DIR, "treino.txt")
TESTE_FILE = os.path.join(DATA_DIR, "teste.txt")

VOGAIS_REGEX = re.compile(r"[aeiouáàâãéêíóôõú]", re.IGNORECASE)
TOKEN_REGEX = re.compile(r"[a-záàâãéêíóôõúç]+", re.IGNORECASE)

def passo_1_divisao(seed=42):
    print(">>> [PASSO 1/5] Divisão 80/20 Reproduzível...")
    with open(CORPUS_FILE, "r", encoding="utf-8") as f:
        linhas = [l.strip() for l in f if l.strip()]
    
    rng = random.Random(seed)
    # Shuffle reproduzível
    indices = list(range(len(linhas)))
    rng.shuffle(indices)
    shuffled = [linhas[i] for i in indices]
    
    n_treino = int(round(len(shuffled) * 0.8))
    treino = shuffled[:n_treino]
    teste = shuffled[n_treino:]
    
    with open(TREINO_FILE, "w", encoding="utf-8") as f:
        f.write("\n".join(treino) + "\n")
    with open(TESTE_FILE, "w", encoding="utf-8") as f:
        f.write("\n".join(teste) + "\n")
        
    print(f"Total: {len(linhas)} linhas | Treino: {len(treino)} (80%) | Teste: {len(teste)} (20%)")

def extrair_vocabulario_com_freq(filepath):
    freq = {}
    with open(filepath, "r", encoding="utf-8") as f:
        for linha in f:
            tokens = TOKEN_REGEX.findall(linha.lower())
            for t in tokens:
                freq[t] = freq.get(t, 0) + 1
    return freq

def passo_2_contracao():
    print(">>> [PASSO 2/5] Geração por Contração (Remoção de Vogais)...")
    freq = extrair_vocabulario_com_freq(TREINO_FILE)
    mapa_abrev = {} # abrev -> (palavra, freq)
    
    for p, f in freq.items():
        abrev = VOGAIS_REGEX.sub("", p)
        # Deve ter carateres e ser estritamente menor que a palavra original
        if len(abrev) > 0 and len(abrev) < len(p):
            if abrev not in mapa_abrev or f > mapa_abrev[abrev][1]:
                mapa_abrev[abrev] = (p, f)
                
    out_file = os.path.join(RESULTS_DIR, "abreviaturas_contracao.txt")
    # Formato: coluna 1 = abreviatura, coluna 2 = palavra original (separadas por TAB)
    with open(out_file, "w", encoding="utf-8") as f:
        for abrev in sorted(mapa_abrev.keys()):
            f.write(f"{abrev}\t{mapa_abrev[abrev][0]}\n")
            
    print(f"Abreviaturas geradas (Contração): {len(mapa_abrev)} -> {out_file}")

def passo_3_truncagem():
    print(">>> [PASSO 3/5] Geração por Truncagem (Prefixos Mínimos Únicos)...")
    freq = extrair_vocabulario_com_freq(TREINO_FILE)
    vocab = list(freq.keys())
    
    # Contagem de partilha de prefixos
    pref_counts = {}
    for p in vocab:
        for L in range(1, len(p)):
            pref = p[:L]
            pref_counts[pref] = pref_counts.get(pref, 0) + 1
            
    abrevs = {}
    for p in vocab:
        min_L = 2 if len(p) >= 3 else 1
        for L in range(min_L, len(p)):
            pref = p[:L]
            if pref_counts[pref] == 1:
                abrevs[pref] = p
                break
                
    out_file = os.path.join(RESULTS_DIR, "abreviaturas_truncagem.txt")
    with open(out_file, "w", encoding="utf-8") as f:
        for abrev in sorted(abrevs.keys()):
            f.write(f"{abrev}\t{abrevs[abrev]}\n")
            
    print(f"Abreviaturas geradas (Truncagem): {len(abrevs)} -> {out_file}")

def passo_4_metodo3():
    print(">>> [PASSO 4/5] Geração pelo Método 3 (MCSF - Saliência Consonantal e Frequência)...")
    freq = extrair_vocabulario_com_freq(TREINO_FILE)
    
    # Filtrar palavras com >= 4 letras e ordenar por frequência decrescente
    candidatos = [p for p in freq.keys() if len(p) >= 4]
    candidatos.sort(key=lambda p: (freq[p], len(p)), reverse=True)
    
    mapa_ocupado = {} # abrev -> palavra
    resultado = {}
    
    for p in candidatos:
        primeira_letra = p[0]
        resto = p[1:]
        consoantes = VOGAIS_REGEX.sub("", resto)
        n_cons = len(consoantes)
        
        abrev_escolhida = None
        
        # Nível 1: Primeira letra + 1ª consoante subsequente (2 letras)
        if n_cons >= 1:
            c1 = primeira_letra + consoantes[0]
            if c1 not in mapa_ocupado and len(c1) < len(p):
                abrev_escolhida = c1
                
        # Nível 2: Primeira letra + 2 primeiras consoantes subsequentes (3 letras)
        if not abrev_escolhida and n_cons >= 2:
            c2 = primeira_letra + consoantes[:2]
            if c2 not in mapa_ocupado and len(c2) < len(p):
                abrev_escolhida = c2
                
        # Nível 3: Primeira letra + 1ª consoante + última letra da palavra (3 letras)
        if not abrev_escolhida and n_cons >= 1:
            c3 = primeira_letra + consoantes[0] + p[-1]
            if c3 not in mapa_ocupado and len(c3) < len(p):
                abrev_escolhida = c3
                
        # Nível 4: Prefixo de 3 ou 4 letras
        if not abrev_escolhida:
            for L in [3, 4]:
                if L < len(p):
                    pref = p[:L]
                    if pref not in mapa_ocupado:
                        abrev_escolhida = pref
                        break
                        
        if abrev_escolhida:
            mapa_ocupado[abrev_escolhida] = p
            resultado[abrev_escolhida] = p
            
    out_file = os.path.join(RESULTS_DIR, "abreviaturas_metodo3.txt")
    with open(out_file, "w", encoding="utf-8") as f:
        for abrev in sorted(resultado.keys()):
            f.write(f"{abrev}\t{resultado[abrev]}\n")
            
    print(f"Abreviaturas geradas (Método 3 MCSF): {len(resultado)} -> {out_file}")

def simular_escrita(metodo_nome, abrev_filepath):
    # Carregar dicionário: palavra_original -> abreviatura
    dict_palavras = {}
    with open(abrev_filepath, "r", encoding="utf-8") as f:
        for linha in f:
            partes = linha.strip().split("\t")
            if len(partes) == 2:
                abrev, palavra = partes[0], partes[1].lower()
                if palavra not in dict_palavras or len(abrev) < len(dict_palavras[palavra]):
                    dict_palavras[palavra] = abrev
                    
    total_palavras = 0
    palavras_substituidas = 0
    caracteres_originais = 0
    poupanca_total = 0
    
    with open(TESTE_FILE, "r", encoding="utf-8") as f:
        for linha in f:
            tam_orig = len(linha)
            caracteres_originais += tam_orig
            
            linha_limpa = linha.lower()
            tokens = TOKEN_REGEX.findall(linha_limpa)
            
            poupanca_linha = 0
            for t in tokens:
                total_palavras += 1
                if t in dict_palavras:
                    abrev = dict_palavras[t]
                    palavras_substituidas += 1
                    dif = len(t) - len(abrev)
                    if dif > 0:
                        poupanca_linha += dif
                        
            poupanca_total += poupanca_linha
            
    caracteres_abreviados = caracteres_originais - poupanca_total
    poupanca_pct = (poupanca_total / caracteres_originais * 100.0) if caracteres_originais > 0 else 0.0
    cobertura_pct = (palavras_substituidas / total_palavras * 100.0) if total_palavras > 0 else 0.0
    
    return {
        "metodo": metodo_nome,
        "total_palavras": total_palavras,
        "substituidas": palavras_substituidas,
        "cobertura_pct": cobertura_pct,
        "caract_orig": caracteres_originais,
        "caract_abrev": caracteres_abreviados,
        "poupanca_caract": poupanca_total,
        "poupanca_pct": poupanca_pct
    }

def passo_5_simulacao():
    print("\n>>> [PASSO 5/5] Simulação da Escrita e Avaliação Comparativa...")
    resultados = [
        simular_escrita("Contração", os.path.join(RESULTS_DIR, "abreviaturas_contracao.txt")),
        simular_escrita("Truncagem", os.path.join(RESULTS_DIR, "abreviaturas_truncagem.txt")),
        simular_escrita("Método 3 (MCSF)", os.path.join(RESULTS_DIR, "abreviaturas_metodo3.txt"))
    ]
    
    csv_file = os.path.join(RESULTS_DIR, "metricas_comparativas.csv")
    with open(csv_file, "w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f, delimiter=";")
        writer.writerow(["Metodo", "Total_Palavras", "Palavras_Substituidas", "Taxa_Cobertura_Pct", 
                         "Caracteres_Original", "Caracteres_Abreviado", "Poupança_Caracteres", "Poupanca_Pct"])
        for r in resultados:
            writer.writerow([r["metodo"], r["total_palavras"], r["substituidas"], f"{r['cobertura_pct']:.2f}",
                             r["caract_orig"], r["caract_abrev"], r["poupanca_caract"], f"{r['poupanca_pct']:.2f}"])
            
    print("\n" + "="*88)
    print(f"{'Abordagem':<18} | {'Substituídas':<12} | {'Cobertura':<10} | {'Caract. Orig.':<14} | {'Caract. Abr.':<13} | {'Poupança (%)':<12}")
    print("-" * 88)
    for r in resultados:
        print(f"{r['metodo']:<18} | {r['substituidas']:<4} / {r['total_palavras']:<5} | {r['cobertura_pct']:>6.2f}%   | {r['caract_orig']:<14} | {r['caract_abrev']:<13} | {r['poupanca_pct']:>8.2f}%")
    print("="*88)
    print(f"Resultados detalhados guardados em: {csv_file}\n")

if __name__ == "__main__":
    passo_1_divisao()
    passo_2_contracao()
    passo_3_truncagem()
    passo_4_metodo3()
    passo_5_simulacao()
