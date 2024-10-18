
#!/bin/bash

OPTIONS=(selecionar_arquivo adicionar_filtro_coluna limpar_filtros_colunas mostrar_duracao_media_reclamacao mostrar_ranking_reclamacoes mostrar_reclamacoes sair)
COLUMNS=("Data de abertura" Canal Tema Assunto Serviço Logradouro Número CEP Subprefeitura Distrito Latitude Longitude "Data do Parecer" "Status da solicitação" Orgão Data Nível "Prazo Atendimento" "Qualidade Atendimento" "Atendeu Solicitação")

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
grep $1 filter/f.csv > temp.csv && mv temp.csv filter/f.csv #ira selecionar as linhas do arquivo f.csv que possuem o filtro selecionado, mandar para um arquivo temporario e dps colocar o conteudo do arq temporario em f.csv

#OBS : a pasta filter e o arquivo f.csv deverao ser criados logo apos o arquivo de trabalho ser selecionando
# o arquivo f.csv devera ser uma copia do arquivo selecionado
# quando mudarmos de arquivo o arquivo f.csv precisa ser att

arrayfilters[$filterCount]="$2 = $1" #esse array armazena quais filtros estão ativos no arquivo atual, quando mudar de arquivo precisamos zerar essa variavel
let filterCount=$filterCount+1 #quando mudar de arquivo precisamos zerar essa variavel

echo "+++ Adicionando filtro: $2 = $1"
echo "+++ Arquivo atual: ${actualFile}"
echo "+++ Filtros atuais:"
echo "${arrayfilters[*]}"
}

function cleanAllFilters {
#essa função limpa todos filtros selecionados

cat dados/$actualFile > filter/f.csv #reseto o arquivo f.csv
arrayfilters=() #zerando o arrayfilters
let filterCount=0 #zerando essa variavel
echo "+++ Filtros removidos"
echo "+++ Arquivo atual: ${actualFile}"
echo "+++ Filtros atuais:"
echo "${arrayfilters[*]}"


}

function interface_inicial {
#essa funcao cria uma interface e executa um comando de acordo com a opção selecionada pelo usuário
echo "Escolha uma opção de operação:"
select option in "${OPTIONS[@]}"; do 
    
    if [[ $REPLY -eq 1 ]]; then
        echo ' '
        interface_1
    
    elif [[ $REPLY -eq 2 ]]; then
        echo ' '
        interface_2
    fi

done
}

function interface_1 {
#essa funcao cria uma interface com as opções de arquivos para serem selecionados
local DIRETORIO="dados"
echo "Escolha uma opção de arquivo:"
select ARQ in "$DIRETORIO"/*; do                    #seleciona um arquivo dentre os baixados na pasta "dados"
    LINHAS=$(wc -l < "filter/f.csv")                #linhas do arquivo com filtros atual = numero de reclamacoes
    actualFile="$ARQ"                               #troca para o arquivo selecionado
    filterCount=0                                   #zera o contador de filtros ao trocarmos de arquivo
    arrayfilters=()                                 #zera o array de filtros ao trocarmos de arquivo
    echo +++ Arquivo atual: $ARQ 
    echo +++ Número de reclamações: $LINHAS
    echo +++++++++++++++++++++++++++++++++++++++
    echo ' '
    interface_inicial                               #volta à interface inicial

done
}

function interface_2 {
#essa funcao cria uma interface com as opções de coluna para o filtro
echo "Escolha uma opção de coluna para o filtro:"
select COLUMN in "${COLUMNS[@]}"; do
    IFSOLD=$IFS                                                                              #salvo o valor de IFS em IFSOLD
    IFS=';'                                                                                  #quero separar os itens por ";" entao altero IFS=';'
    cat "dados/$actualFile" | tail -n +2 |cut -d"$IFS" -f$REPLY | sort -u  > kleber.txt      #crio um arquivo "kleber.txt" onde cada linha é  uma opcao de filtro
IFS='
'
    i=0
    for line in $( cat kleber.txt ); do
        echo $line
        filters[$i]=$line                           #armazeno as linhas do arquivo "kleber.txt" em um vetor 
        let i=$i+1
    done

    echo "Escolha uma opção de valor para Canal:"
    select filter in "${filters[@]}"; do            #select com os itens do vetor, os quais sao as opcoes de filtro
        if [[ -n $filter ]]; then
            IFS=$IFSOLD                             #recupero IFS para operações futuras
            setFilter $filter $COLUMN               #call da funcao setFilter passando os parâmetros necessários (filtro desejado e coluna na qual será aplicado)
        break
        fi
    done  

done
}




 #quando mudar de arquivo precisamos a zerar
filterCount=0 #quantidade de filtro implementados

#arquivo atual que estamos trabalhando,quando mudar de arq precisa ser atualizada
actualFile=arquivocompleto.csv 


function setFilter {

#argumento1 : filtro que queremos aplicar ex:(coluba :qualidade de atendimento , filtro : boa)
#argumento2 : coluna que queremos aplicar o filtro
#coloca um filtro na coluna
grep $1 filter/f.csv > temp.csv && mv temp.csv filter/f.csv #ira selecionar as linhas do arquivo f.csv que possuem o filtro selecionado, mandar para um arquivo temporario e dps colocar o conteudo do arq temporario em f.csv



#OBS : a pasta filter e o arquivo f.csv deverao ser criados logo apos o arquivo de trabalho ser selecionando
# o arquivo f.csv devera ser uma copia do arquivo selecionado
# quando mudarmos de arquivo o arquivo f.csv precisa ser att

arrayfilters[$filterCount]="$2 = $1" #esse array armazena quais filtros estão ativos no arquivo atual, quando mudar de arquivo precisamos zerar essa variavel
let filterCount=$filterCount+1 #quando mudar de arquivo precisamos zerar essa variavel
echo " "
echo "+++ Adicionando filtro: $2 = $1"
echo "+++ Arquivo atual: ${actualFile}"
echo "+++ Filtros atuais:"
echo "${arrayfilters[*]}"
}

function cleanAllFilters {
#essa função limpa todos filtros selecionados

cat dados/$actualFile > filter/f.csv #reseto o arquivo f.csv
arrayfilters=() #zerando o arrayfilters
let filterCount=0 #zerando essa variavel
echo "+++ Filtros removidos"
echo "+++ Arquivo atual: ${actualFile}"
echo "+++ Filtros atuais:"
echo "${arrayfilters[*]}"


}

 function showcompliments {
    #essa funcao mostra o top 5 valores ,da coluna, com maiores reclamacoes
    # $1 = numero da coluna que queremos mostrar o top 5 de recamacoes
     #quantidade linhas das reclamções acumuladas
    IFSOLD=$IFS
    echo " "
    echo "+++ Serviço com mais reclamações:"    
    local counter=1
IFS='
'  
    for line in $( cat filter/f.csv | tail -n +2 | cut -d";" -f"$1" | sort | uniq -c | sort -n -r );do
        if [ $counter -gt 5 ]; then 
            break
        fi

        echo $line

        let counter=$counter+1
    done
    echo "+++++++++++++++++++++++++++++++++++++++"    

    IFS=$IFSOLD
 }



# function avarageduration {

# #Mostra o tempo de duração médio de uma reclamação em dias




# }






function makeHeader {
#essa funcao faz printa o header do programa
echo "+++++++++++++++++++++++++++++++++++++++"
echo "Este programa mostra estatísticas do"

echo "Serviço 156 da Prefeitura de São Paulo"
echo "+++++++++++++++++++++++++++++++++++++++"
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
   
    if [ -e $1 ]; then
        #se existir o arquido das urls 


        downloadFIles $1 #BAIXA OS ARQUIVOS DAS URLS

        #concatena o conteudo de todos arquivos no arquivo compelto
        if [ -e dados/arquivocompleto.csv ]; then
            rm dados/arquivocompleto.csv
        fi

        ls dados | parallel -k cat dados/{} > arquivocompleto.csv
        
        mv arquivocompleto.csv dados/


        createFilterData #CRIA A PASTA FILTER E O ARQUIVO F.CSV PARA A MANIPULACAO DOS FILTROS

    else 
        #SE NAO EXISTIR O ARQUIVO DAS URLS
        echo "ERRO : o arquivo ${1} não existe"
    fi   
    
    
    #BAIXA O ARQUIVO E entra na interface


elif [ $# -eq 0 ]; then
    #ENTRA AQUI QUANDO RODAMOS O SCRIPT SEM ARGUMENTO


    if [ -e dados/arquivocompleto.csv ]; then
        #ENTRA AQUI SE EXISTE ARQUIVOS DA URLS JA BAIXADOS


         createFilterData
         echo "entra na interface com os arquivos atuais"
        
        setFilter FINALIZADA "STATUS DA SOLICITAÇÃO" #adiciona o filtro CHATBOT na coluna Canal
        #  setFilter SMDHC Orgao #adiciona o filtro SMDHC na coluna Orgao
        #  cleanAllFilters #LIMPA TODOS FILTROS
        #  setFilter CHATBOT Canal #adiciona o filtro CHATBOT na coluna Canal


    else 
        echo "ERRO : Não há dados baixados"
        echo "Para baixar os dados antes de gerar as estátísticas, use:"
        echo "./ep2_servico156.sh <nome do arquivo com URLs de dados do Serviço 156>"
    fi

fi
}

main

exit 0






