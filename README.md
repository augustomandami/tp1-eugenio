cat << 'EOF' > setup.sh
#!/bin/bash
set -e

echo "=== Configurando projeto TP1 Eugenio ==="
mkdir -p data scripts results output docs

# 1. Criar Corpus de Exemplo em data/corpus.txt
cat << 'CORPUS_EOF' > data/corpus.txt
Olá bom dia a todos.
Como estás hoje?
Eu estou bem obrigado.
Eu preciso de ajuda por favor.
Quero beber um copo de água fresca.
Tenho muita sede e quero beber água agora.
Tenho fome e quero comer alguma coisa.
A que horas é o almoço hoje?
Gostava de comer sopa de legumes e peixe grelhado.
Por favor podes ligar a televisão no canal de notícias?
Quero ver o programa sobre a natureza e os animais selvagens.
Onde está o comando da televisão?
Não consigo alcançar o livro que está na mesa da sala.
Podes chegar o livro mais para perto de mim?
Muito obrigado pela tua ajuda e paciência.
Estou com frio por favor fecha a janela do quarto.
Podes pôr uma manta quente nas minhas pernas?
Agora estou mais confortável e sem frio.
Tenho calor podes abrir um pouco a porta da varanda?
Preciso de tomar os meus medicamentos da manhã.
Onde está a caixa dos comprimidos azuis?
Sinto uma dor de cabeça forte deste lado.
Podes chamar o médico ou o enfermeiro de serviço?
A enfermeira disse que a medicação chega daqui a pouco.
Quero descansar um pouco e dormir uma sesta.
Apaga a luz do quarto antes de saíres por favor.
Amanhã temos consulta de fisioterapia logo pela manhã.
A sessão de fisioterapia ajuda a relaxar os músculos e a respirar melhor.
O terapeuta é muito simpático e paciente comigo.
Hoje sinto-me com mais energia e boa disposição.
Gostava de ir passear ao jardim da cidade durante a tarde.
O tempo está ensolarado com céu azul e sem vento.
Vamos ver as flores coloridas e as árvores do parque.
Adoro ouvir o canto dos pássaros junto ao lago.
O sistema Eugénio permite-me comunicar com a família e com os amigos.
A comunicação é um direito fundamental de todas as pessoas.
Com este computador consigo escrever mensagens e expressar as minhas ideias.
As abreviaturas ajudam a poupar esforço e tempo na escrita no ecrã.
A escrita com poupança de caracteres é muito importante para nós.
Quando escrevo menos letras fico menos cansado e comunico mais depressa.
O teclado virtual do sistema tem várias configurações acessíveis.
Podemos selecionar as opções através do varrimento automático ou com manípulos.
A tecnologia de apoio faz uma grande diferença na vida diária.
Quero telefonar à minha mãe e falar com ela sobre o meu dia.
Ela vai ficar muito contente por receber a minha mensagem de texto.
O meu irmão vem visitar-me este fim de semana com os meus sobrinhos.
Eles gostam de brincar aos jogos de tabuleiro e de ver desenhos animados.
Vou pedir-lhe para trazer o meu computador portátil e os auscultadores.
Preciso de carregar a bateria do telemóvel porque está quase a acabar.
Onde deixei o cabo de carregamento rápido e o transformador?
Podes verificar se o telemóvel tem rede e ligação à internet sem fios?
Quero enviar uma mensagem de correio eletrónico ao meu professor da universidade.
O trabalho prático de sistemas operativos é sobre abreviaturas e processamento de texto.
Estamos a utilizar comandos e utilitários do sistema operativo Linux para processar ficheiros.
O terminal do Linux oferece ferramentas poderosas como sed awk tr sort e uniq.
Com estas ferramentas conseguimos filtrar dividir e transformar grandes volumes de informação.
A avaliação do trabalho inclui uma defesa oral onde temos de explicar todo o código.
É muito importante compreender o funcionamento de cada instrução e script desenvolvido.
O relatório técnico deve descrever com rigor a metodologia e os resultados obtidos.
Vamos comparar a técnica da contração com a técnica da truncagem e um método inovador.
A contração remove as vogais das palavras e mantém a estrutura consonântica.
A truncagem utiliza apenas os primeiros caracteres da palavra original.
O método livre pode combinar a frequência das palavras com a seleção de caracteres salientes.
As palavras mais frequentes na língua portuguesa devem ter abreviaturas mais curtas.
Abreviações ambíguas podem gerar confusão e diminuir a velocidade de comunicação.
Por isso o algoritmo deve evitar colisões entre palavras distintas no dicionário.
A percentagem de poupança de esforço mede a redução no número de teclas premidas.
Uma poupança elevada significa maior eficiência e menor fadiga física para o utilizador.
O desenvolvimento deste projeto contribui para a acessibilidade digital e inclusão social.
Todos os cidadãos devem ter acesso a ferramentas que facilitem a sua autonomia pessoal.
Hoje em dia os sistemas computacionais estão cada vez mais inteligentes e adaptáveis.
A inteligência artificial apoia a criação de soluções inovadoras na área da saúde.
Contudo o utilizador deve manter sempre o controlo final sobre a mensagem transmitida.
Vou guardar este documento e fazer uma cópia de segurança no disco externo.
Nunca devemos esquecer de fazer cópias de segurança dos ficheiros importantes.
Podes trazer-me um copo de sumo de laranja natural com gelo?
A comida hoje estava muito saborosa especialmente o puré de batata.
Gostava de comer uma fruta fresca como sobremesa talvez uma maçã ou uma banana.
Amanhã vou começar o dia a ler as notícias no jornal digital.
Gosto de estar informado sobre os acontecimentos no país e no mundo inteiro.
A música clássica ajuda-me a concentrar enquanto trabalho no relatório.
Podes colocar a lista de reprodução com músicas calmas e relaxantes?
O som ambiente está demasiado alto podes diminuir o volume das colunas?
Muito obrigado pelo teu apoio carinho e dedicação de todos os dias.
Tenham todos uma excelente tarde e um bom descanso esta noite.
Até amanhã se Deus quiser e fiquem todos bem com muita saúde e paz.
CORPUS_EOF

# 2. Script 01: Separação de Dados (80% treino / 20% teste)
cat << 'S1_EOF' > scripts/01_separacao_dados.sh
#!/bin/bash
set -euo pipefail
CORPUS_FILE="${1:-data/corpus.txt}"
SEED="${2:-42}"
TREINO_FILE="data/treino.txt"
TESTE_FILE="data/teste.txt"

TOTAL_LINHAS=$(grep -cve '^\s*$' "$CORPUS_FILE" || true)
LINHAS_TREINO=$(awk -v total="$TOTAL_LINHAS" 'BEGIN { printf "%d\n", (total * 0.80) + 0.5 }')
LINHAS_TESTE=$(( TOTAL_LINHAS - LINHAS_TREINO ))

TEMP_SHUFFLED=$(mktemp)
awk -v seed="$SEED" '
    BEGIN { srand(seed) }
    NF > 0 { print rand() "\t" $0 }
' "$CORPUS_FILE" | sort -k1,1n | cut -f2- > "$TEMP_SHUFFLED"

head -n "$LINHAS_TREINO" "$TEMP_SHUFFLED" > "$TREINO_FILE"
tail -n "$LINHAS_TESTE" "$TEMP_SHUFFLED" > "$TESTE_FILE"
rm -f "$TEMP_SHUFFLED"
echo "[01] Divisao concluida: Treino ($LINHAS_TREINO linhas), Teste ($LINHAS_TESTE linhas)."
S1_EOF

# 3. Script 02: Contração
cat << 'S2_EOF' > scripts/02_contracao.sh
#!/bin/bash
set -euo pipefail
TREINO_FILE="${1:-data/treino.txt}"
OUT_FILE="results/abreviaturas_contracao.txt"

awk '
{
    linha = tolower($0)
    gsub(/[.,;:!?()«»"'\''_—\-\/\\]/, " ", linha)
    n = split(linha, palavras, " ")
    for (i = 1; i <= n; i++) {
        p = palavras[i]
        if (p ~ /^[a-záàâãéêíóôõúç]+$/) { freq[p]++ }
    }
}
END {
    for (p in freq) {
        abrev = p
        gsub(/[aeiouáàâãéêíóôõú]/, "", abrev)
        if (length(abrev) > 0 && length(abrev) < length(p)) {
            if (!(abrev in mapa) || freq[p] > freq_mapa[abrev]) {
                mapa[abrev] = p
                freq_mapa[abrev] = freq[p]
            }
        }
    }
    for (abrev in mapa) {
        print abrev "\t" mapa[abrev]
    }
}
' "$TREINO_FILE" | sort -k1,1 > "$OUT_FILE"

cp "$OUT_FILE" output/abreviaturas_contracao.txt
echo "[02] Contracao concluida: $(wc -l < "$OUT_FILE") abreviaturas geradas."
S2_EOF

# 4. Script 03: Truncagem
cat << 'S3_EOF' > scripts/03_truncagem.sh
#!/bin/bash
set -euo pipefail
TREINO_FILE="${1:-data/treino.txt}"
OUT_FILE="results/abreviaturas_truncagem.txt"

awk '
{
    linha = tolower($0)
    gsub(/[.,;:!?()«»"'\''_—\-\/\\]/, " ", linha)
    n = split(linha, palavras, " ")
    for (i = 1; i <= n; i++) {
        p = palavras[i]
        if (p ~ /^[a-záàâãéêíóôõúç]+$/) { vocab[p] = 1 }
    }
}
END {
    total = 0
    for (p in vocab) { lista[++total] = p }
    for (i = 1; i <= total; i++) {
        p = lista[i]
        for (L = 1; L < length(p); L++) {
            prefix_count[substr(p, 1, L)]++
        }
    }
    for (i = 1; i <= total; i++) {
        p = lista[i]
        min_L = (length(p) >= 3) ? 2 : 1
        for (L = min_L; L < length(p); L++) {
            pref = substr(p, 1, L)
            if (prefix_count[pref] == 1) {
                print pref "\t" p
                break
            }
        }
    }
}
' "$TREINO_FILE" | sort -k1,1 > "$OUT_FILE"

cp "$OUT_FILE" output/abreviaturas_truncagem.txt
echo "[03] Truncagem concluida: $(wc -l < "$OUT_FILE") abreviaturas geradas."
S3_EOF

# 5. Script 04: Método 3 (MCSF)
cat << 'S4_EOF' > scripts/04_metodo3.sh
#!/bin/bash
set -euo pipefail
TREINO_FILE="${1:-data/treino.txt}"
OUT_FILE="results/abreviaturas_metodo3.txt"

awk '
{
    linha = tolower($0)
    gsub(/[.,;:!?()«»"'\''_—\-\/\\]/, " ", linha)
    n = split(linha, palavras, " ")
    for (i = 1; i <= n; i++) {
        p = palavras[i]
        if (p ~ /^[a-záàâãéêíóôõúç]+$/) { freq[p]++ }
    }
}
END {
    tot = 0
    for (p in freq) {
        if (length(p) >= 4) { lista[++tot] = p }
    }
    for (i = 1; i <= tot; i++) {
        for (j = i + 1; j <= tot; j++) {
            if (freq[lista[j]] > freq[lista[i]]) {
                tmp = lista[i]; lista[i] = lista[j]; lista[j] = tmp
            }
        }
    }
    for (i = 1; i <= tot; i++) {
        p = lista[i]; len = length(p)
        p1 = substr(p, 1, 1); resto = substr(p, 2)
        gsub(/[aeiouáàâãéêíóôõú]/, "", resto)
        abrev = ""
        if (length(resto) >= 1 && !(p1 substr(resto, 1, 1) in mapa)) {
            abrev = p1 substr(resto, 1, 1)
        } else if (length(resto) >= 2 && !(p1 substr(resto, 1, 2) in mapa)) {
            abrev = p1 substr(resto, 1, 2)
        } else if (length(resto) >= 1 && !(p1 substr(resto, 1, 1) substr(p, len, 1) in mapa)) {
            abrev = p1 substr(resto, 1, 1) substr(p, len, 1)
        }
        if (abrev != "" && length(abrev) < len) {
            mapa[abrev] = p
            print abrev "\t" p
        }
    }
}
' "$TREINO_FILE" | sort -k1,1 > "$OUT_FILE"

cp "$OUT_FILE" output/abreviaturas_metodo3.txt
echo "[04] Metodo 3 concluido: $(wc -l < "$OUT_FILE") abreviaturas geradas."
S4_EOF

# 6. Script 05: Simulação da Escrita
cat << 'S5_EOF' > scripts/05_simula_escrita.sh
#!/bin/bash
set -euo pipefail
TESTE_FILE="${1:-data/teste.txt}"
METRICAS_CSV="results/metricas_comparativas.csv"

simular() {
    local nome="$1"
    local arq="$2"
    awk -v met="$nome" -v f_abrev="$arq" '
    BEGIN {
        while ((getline l < f_abrev) > 0) {
            split(l, c, "\t")
            if (length(c[1]) > 0 && length(c[2]) > 0) { dict[tolower(c[2])] = c[1] }
        }
        close(f_abrev)
    }
    {
        tam = length($0) + 1
        orig += tam
        l_clean = tolower($0)
        gsub(/[.,;:!?()«»"'\''_—\-\/\\]/, " ", l_clean)
        n = split(l_clean, w, " ")
        poup_lin = 0
        for (i = 1; i <= n; i++) {
            if (w[i] ~ /^[a-záàâãéêíóôõúç]+$/) {
                tot_p++
                if (w[i] in dict) {
                    subst++
                    dif = length(w[i]) - length(dict[w[i]])
                    if (dif > 0) poup_lin += dif
                }
            }
        }
        abrev_total += (tam - poup_lin)
    }
    END {
        poup_pct = (orig > 0) ? ((orig - abrev_total) / orig) * 100.0 : 0
        cob_pct = (tot_p > 0) ? (subst / tot_p) * 100.0 : 0
        printf "%s;%d;%d;%.2f;%d;%d;%.2f\n", met, tot_p, subst, cob_pct, orig, abrev_total, poup_pct
    }
    ' "$TESTE_FILE"
}

echo "Metodo;Total_Palavras;Palavras_Substituidas;Taxa_Cobertura_Pct;Caracteres_Original;Caracteres_Abreviado;Poupanca_Pct" > "$METRICAS_CSV"
simular "Contracao" "results/abreviaturas_contracao.txt" >> "$METRICAS_CSV"
simular "Truncagem" "results/abreviaturas_truncagem.txt" >> "$METRICAS_CSV"
simular "Metodo3_MCSF" "results/abreviaturas_metodo3.txt" >> "$METRICAS_CSV"
cp "$METRICAS_CSV" output/metricas_comparativas.csv

echo ""
echo "=========================================================================================="
echo "          Simulação Comparativa da Escrita - Métricas do Sistema Eugénio"
echo "=========================================================================================="
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
S5_EOF

# 7. Script Mestre run_all.sh
cat << 'RUN_EOF' > scripts/run_all.sh
#!/bin/bash
set -euo pipefail
echo ">>> Executando pipeline completo..."
./scripts/01_separacao_dados.sh data/corpus.txt 42
./scripts/02_contracao.sh data/treino.txt
./scripts/03_truncagem.sh data/treino.txt
./scripts/04_metodo3.sh data/treino.txt
./scripts/05_simula_escrita.sh data/teste.txt
echo ">>> Pipeline concluido com sucesso!"
RUN_EOF

chmod +x scripts/*.sh
echo "=== Todos os scripts gerados e permissões atribuídas! ==="
EOF

chmod +x setup.sh
./setup.sh
