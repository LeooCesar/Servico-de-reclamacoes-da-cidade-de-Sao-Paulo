
#!/bin/bash
##################################################################
# MAC0216 - Técnicas de Programação I (2024)
# EP2 - Programação em Bash
#
# Nome do(a) aluno(a) 1: Leonardo César da Silva Francisco 
# NUSP 1: 15468897
#
# Nome do(a) aluno(a) 2: Nattan Ferreira da Silva
# NUSP 2: 15520641
##################################################################

OPTIONS=(selecionar_arquivo adicionar_filtro_coluna limpar_filtros_colunas mostrar_duracao_media_reclamacao mostrar_ranking_reclamacoes mostrar_reclamacoes sair)

#quando mudar de arquivo precisamos a zerar
filterCount=0 #quantidade de filtro implementados

#arquivo atual que estamos trabalhando,quando mudar de arq precisa ser atualizada
actualFile=arquivocompleto.csv 



function createFilterData {

if [ ! -e filter ]; then
#essa funcao cria a pasta filter, se nao existir, e coloca o conteudo do actualFile no arquivo f.csv
    mkdir filter
fi

cp dados/$actualFile filter/f.csv


}




function setFilter {

#argumento1 : filtro que queremos aplicar ex:(coluna :qualidade de atendimento , filtro : boa)
#argumento2 : coluna que queremos aplicar o filtro
#coloca um filtro na coluna
grep "$1" filter/f.csv > temp.csv && mv temp.csv filter/f.csv #ira selecionar as linhas do arquivo f.csv que possuem o filtro selecionado, mandar para um arquivo temporario e dps colocar o conteudo do arq temporario em f.csv

#OBS : a pasta filter e o arquivo f.csv deverao ser criados logo apos o arquivo de trabalho ser selecionando
# o arquivo f.csv devera ser uma copia do arquivo selecionado
# quando mudarmos de arquivo o arquivo f.csv precisa ser att
if [ ${#arrayfilters[*]} -gt 0 ]; then
    #se ja tem filtro add |
    arrayfilters[$filterCount]="| $2 = $1" #esse array armazena quais filtros estão ativos no arquivo atual, quando mudar de arquivo precisamos zerar essa variavel
else
    arrayfilters[$filterCount]="$2 = $1" #esse array armazena quais filtros estão ativos no arquivo atual, quando mudar de arquivo precisamos zerar essa variavel
fi
let filterCount=$filterCount+1 #quando mudar de arquivo precisamos zerar essa variavel
echo " "
echo "+++ Adicionando filtro: $2 = $1"
echo "+++ Arquivo atual: ${actualFile}"
echo "+++ Filtros atuais:"
echo "${arrayfilters[*]}"
echo "+++ Número de reclamações: $(cat filter/f.csv | wc -l  )"  
echo "+++++++++++++++++++++++++++++++++++++++"
echo ' '
}

function cleanAllFilters {
#essa função limpa todos filtros selecionados

cat dados/$actualFile > filter/f.csv #reseto o arquivo f.csv

arrayfilters=() #zerando o arrayfilters
let filterCount=0 #zerando essa variavel
echo " "
echo "+++ Filtros removidos"
echo "+++ Arquivo atual: ${actualFile}"
echo "+++ Número de reclamações: $(tail -n+2 filter/f.csv | wc -l  )"  
echo "+++++++++++++++++++++++++++++++++++++++"
echo ' '


}

function interface_inicial {
#essa funcao cria uma interface e executa um comando de acordo com a opção selecionada pelo usuário
echo "Escolha uma opção de operação:"
select option in "${OPTIONS[@]}"; do 
    echo ' '
    interface_$REPLY
    
done
}



function interface_1 {
#essa funcao cria uma interface com as opções de arquivos para serem selecionados
echo "Escolha uma opção de arquivo:"
select ARQ in $( ls dados/ ); do                                           #seleciona um arquivo dentre os baixados na pasta "dados"
    actualFile="$ARQ"                                                      #troca para o arquivo selecionado
    createFilterData
    LINHAS=$(cat "dados/$actualFile" | tail -n +2 | wc -l )                #linhas do arquivo com filtros atual = numero de reclamacoes
    filterCount=0                                                          #zera o contador de filtros ao trocarmos de arquivo
    arrayfilters=()                                                        #zera o array de filtros ao trocarmos de arquivo
    echo +++ Arquivo atual: $ARQ 
    echo +++ Número de reclamações: $LINHAS
    echo +++++++++++++++++++++++++++++++++++++++
    echo ' '
    interface_inicial                                                      #volta à interface inicial

done
}

function interface_2 {
#essa funcao cria uma interface com as opções de coluna para o filtro
echo "Escolha uma opção de coluna para o filtro:"

    IFSOLD=$IFS                                                                              #salvo o valor de IFS em IFSOLD
    IFS=';'                                                                                  #quero separar os itens por ";" entao altero IFS=';'
    read -r -a COLUMNS < <(head -n 1 "dados/arquivocompleto.csv")
select COLUMN in "${COLUMNS[@]}"; do
    if [ ${#arrayfilters[*]} -gt 0 ]; then
        cat "filter/f.csv" | cut -d"$IFS" -f$REPLY | sort -u  > opcoes.txt                    #se tiver filtros, queremos que todas as linhas sejam opções para o usuário
    else
        cat "filter/f.csv" | tail -n +2 | cut -d"$IFS" -f$REPLY | sort -u  > opcoes.txt       #se nao tiver filtros, não queremos que a primeira linha seja uma opção para o usuário
    fi
IFS='
'
    i=0
    for line in $( cat opcoes.txt ); do
        filters[$i]=$line                           #armazeno as linhas do arquivo "opcoes.txt" em um vetor 
        let i=$i+1
    done
    echo ' '
    echo "Escolha uma opção de valor para "$COLUMN":"

    select filter in "${filters[@]}"; do            #select com os itens do vetor, os quais sao as opcoes de filtro
        IFS=$IFSOLD                                 #recupero IFS para operações futuras
        setFilter "$filter" "$COLUMN"               #call da funcao setFilter passando os parâmetros necessários (filtro desejado e coluna na qual será aplicado)
        filters=()
        interface_inicial
        
    done  

done
}

function interface_3 {
#essa funcao apenas redireciona para a funcao que limpa filtros
    cleanAllFilters
    interface_inicial
}

function interface_4 {
#essa funcao apenas redireciona para a funcao que calcula a média de tempo
    avarageduration
    interface_inicial
}

function interface_5 {
#essa funcao cria uma interface para o usuário escolher a coluna que deseja analisar. Depois disso, o número da coluna é passado para a funcao showcomplimentsrank
    echo "Escolha uma opção de coluna para análise:"
    IFSOLD=$IFS                                                                              #salvo o valor de IFS em IFSOLD
    IFS=';'                                                                                  #quero separar os itens por ";" entao altero IFS=';'
    read -r -a COLUMNS < <(head -n 1 "dados/arquivocompleto.csv")
    select COLUMN in "${COLUMNS[@]}"; do
    IFS=$IFSOLD
    showcomplimentsrank $REPLY "$COLUMN"
    interface_inicial

    done
}

function interface_6 {
#essa funcao apenas redireciona para a funcao que mostra todas as reclamações do arquivo atual
    showcompliments
    interface_inicial
}

function interface_7 {
#essa funcao finaliza o programa
    echo "Fim do programa"
    echo "+++++++++++++++++++++++++++++++++++++++"
    exit 0
}



function showcomplimentsrank {
    #essa funcao mostra o top 5 valores ,da coluna, com maiores reclamacoes
    # $1 = numero da coluna que queremos mostrar o top 5 de recamações
    # s2 = nome da coluna
    IFSOLD=$IFS
    echo " "
    echo "+++ $2 com mais reclamações:"    
    local counter=1
    if [ ${#arrayfilters[*]} -gt 0 ]; then #se tem filtro quer dizer q a primeira linha nao representa as colunas
        local cd=$( cat filter/f.csv |  cut -d";" -f"$1" | sort | uniq -c | sort -n -r )    
    else  local cd=$( cat filter/f.csv | tail -n +2 | cut -d";" -f"$1" | sort | uniq -c | sort -n -r )    
    fi
IFS='
'  
    for line in $cd;do
        if [ $counter -gt 5 ]; then 
            break
        fi

        echo $line

        let counter=$counter+1
    done
    echo "+++++++++++++++++++++++++++++++++++++++"
    echo '  '    

    IFS=$IFSOLD
}

function showcompliments {
    #essa funcao mostra todas reclamacoes do arquivo atual
    if [ ${#arrayfilters[*]} -gt 0 ]; then #se tem filtro quer dizer q a primeira linha nao representa as colunas
        cat filter/f.csv
    else tail -n+2 filter/f.csv
    fi
    
    echo "+++ Arquivo atual : $actualFile"
    echo "+++ Filtros atuais:"
    echo "${arrayfilters[*]}"
    echo "+++ Número de reclamações: $(cat filter/f.csv | wc -l  )"  
    echo "+++++++++++++++++++++++++++++++++++++++"
}


 function avarageduration {
    
    #Mostra o tempo de duração médio de uma reclamação em dias
    local cd1=$(cat filter/f.csv | tail -n +2 | cut -d";" -f13)
    local cd2=$(cat filter/f.csv | tail -n +2   |cut -d";" -f1)   
    local arraydataparecer=() #guardara as datas do parecer
    local counter1=0 #servira de contador para a manipulacão de arrays

      if [ ${#arrayfilters[*]} -gt 0 ]; then #se tem filtro quer dizer q a primeira linha nao representa as colunas
         cd1=$(cat filter/f.csv |  cut -d";" -f13) 
         cd2=$(cat filter/f.csv |  cut -d";" -f1) 
        fi

    IFSOLD=$IFS
IFS='
'   



    for line in $cd1; do
        #pega todas datas de parecer , transformo em segundo e coloco no array
        arraydataparecer[counter1]=$( date -d $line +%s)
        let counter1=$counter1+1
    done
    counter1=0


    local soma=0

     for line in $cd2; do
        #para cada data de abertura irei a subtrair pela sua respectiva data do parecer , e somar o resultado na variável soma
        local dataAbertura=$( date -d $line +%s)
        
        let soma=$( echo " ${arraydataparecer[counter1]} - $dataAbertura  " | bc)+$soma

        
        let counter1=$counter1+1
    done
    

    
     media=$( echo "$soma / $counter1 "  | bc ) #calculo a média em segundos

     mediaDias=$( echo "($media / 86400)" | bc) #calculo a média em dias

    IFS=$IFSOLD
    echo " "
    echo "+++ Duração média da reclamação: $mediaDias dias"
    echo "+++++++++++++++++++++++++++++++++++++++"



 }






function makeHeader {
#essa funcao faz printa o header do programa
echo "+++++++++++++++++++++++++++++++++++++++"
echo "Este programa mostra estatísticas do"

echo "Serviço 156 da Prefeitura de São Paulo"
echo "+++++++++++++++++++++++++++++++++++++++"
echo ' ' 
}

function downloadFIles {
#parametro : url do arquivo
#essa funcao baixa os arquivos da url de entrada e faz a transformacao para utf-8
    if [ ! -e dados/ ];then
        mkdir "dados"
    fi
    mkdir "dadostem"
    
    cat $1 | parallel -k "wget -nv {} -P dadostem/" #baixa os arquivos e coloca na pasta data
    for file in $( ls dadostem); do
        iconv -f ISO-8859-1 -t UTF8 dadostem/$file -o dados/$file
    done

    rm -r dadostem


}

function main {
    makeHeader
if [ $# -eq 1 ]; then
    #ENTRA AQUI QUANDO RODAMOS O SCRIPT COM ARGUMENTO
    echo "alouuu"
    if [ -e $1 ]; then
        #se existir o arquido das urls 


        downloadFIles $1 #BAIXA OS ARQUIVOS DAS URLS

        #concatena o conteudo de todos arquivos no arquivo compelto
        if [ -e dados/arquivocompleto.csv ]; then
            rm dados/arquivocompleto.csv
        fi

        #passo o cabeçalho para o arquivo completo
        echo "Data de abertura;Canal;Tema;Assunto;Serviço;Logradouro;Número;CEP;Subprefeitura;Distrito;Latitude;Longitude;Data do Parecer;Status da solicitação;Orgão;Data;Nível;Prazo Atendimento;Qualidade Atendimento;Atendeu Solicitação" > arquivocompleto.csv
        
        #passa cada reclamação dos arquivos para o arquivocompleto
        for file in dados/*; do
            tail -n +2 "$file"
        done >> arquivocompleto.csv
        
        mv arquivocompleto.csv dados/


        createFilterData #CRIA A PASTA FILTER E O ARQUIVO F.CSV PARA A MANIPULACAO DOS FILTROS

        interface_inicial

    else 
        #SE NAO EXISTIR O ARQUIVO DAS URLS
        echo "ERRO : o arquivo ${1} não existe"
    fi   
    
    
    #BAIXA O ARQUIVO E entra na interface


elif [ $# -eq 0 ]; then
    #ENTRA AQUI QUANDO RODAMOS O SCRIPT SEM ARGUMENTO


    if [ -e dados/arquivocompleto.csv ]; then
        #ENTRA AQUI SE EXISTE ARQUIVOS DA URLS JA BAIXADOS

        interface_inicial

    else 
        echo "ERRO : Não há dados baixados"
        echo "Para baixar os dados antes de gerar as estátísticas, use:"
        echo "./ep2_servico156.sh <nome do arquivo com URLs de dados do Serviço 156>"
    fi

fi
}

main $1

exit 0






