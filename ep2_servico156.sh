
#!/bin/bash

OPTIONS=(selecionar_arquivo adicionar_filtro_coluna limpar_filtros_colunas mostrar_duracao_media_reclamacao mostrar_ranking_reclamacoes mostrar_reclamacoes sair)

#quando mudar de arquivo precisamos a zerar
filterCount=0 #quantidade de filtro implementados

#arquivo atual que estamos trabalhando,quando mudar de arq precisa ser atualizada
actualFile=arquivofinal3tri2023.csv 


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
    fi

done
}

function interface_1 {
#essa funcao cria uma interface com as opções de arquivos para serem selecionados
local DIRETORIO="dados"
echo "Escolha uma opção de arquivo:"
select ARQ in "$DIRETORIO"/*; do
    LINHAS=$(wc -l < "$ARQ")
    echo +++ Arquivo atual: $ARQ 
    echo +++ Número de reclamações: $LINHAS
    echo +++++++++++++++++++++++++++++++++++++++
    echo ' '
    interface_inicial

done
}




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

        ls dados | parallel -k cat dados/{}>arquivocompleto.csv
        
        mv arquivocompleto.csv dados/

    else 
        #SE NAO EXISTIR O ARQUIVO DAS URLS
        echo "ERRO : o arquivo ${1} não existe"
    fi   
    
    
    #BAIXA O ARQUIVO E entra na interface


elif [ $# -eq 0 ]; then
    #ENTRA AQUI QUANDO RODAMOS O SCRIPT SEM ARGUMENTO

    if [ -e dados/arquivocompleto.csv ]; then
        #ENTRA AQUI SE EXISTE ARQUIVOS DA URLS JA BAIXADOS
        echo "entra na interface com os arquivos atuais"
        setFilter CHATBOT Canal #adiciona o filtro CHATBOT na coluna Canal
        setFilter SMDHC Orgao #adiciona o filtro SMDHC na coluna Orgao
        cleanAllFilters #LIMPA TODOS FILTROS
        setFilter CHATBOT Canal #adiciona o filtro CHATBOT na coluna Canal

    else 
        echo "ERRO : Não há dados baixados"
        echo "Para baixar os dados antes de gerar as estátísticas, use:"
        echo "./ep2_servico156.sh <nome do arquivo com URLs de dados do Serviço 156>"
    fi

fi









