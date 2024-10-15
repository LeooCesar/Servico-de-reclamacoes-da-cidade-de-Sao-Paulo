
#!/bin/bash


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
    #opcao 1
   
    if [ -e $1 ]; then
        #se existir o arquido das urls


        downloadFIles $1

        #concatena o conteudo de todos arquivos no arquivo compelto
        if [ -e dados/arquivocompleto.csv ]; then
            rm dados/arquivocompleto.csv
        fi

        ls dados | parallel -k cat dados/{}>arquivocompleto.csv
        
        mv arquivocompleto.csv dados/

    else 
        echo "ERRO : o arquivo ${1} não existe"
    fi   
    
    
    
    
    
    #BAIXA O ARQUIVO E entra na interface


elif [ $# -eq 0 ]; then

    if [ -e dados/arquivocompleto.csv ]; then
        echo "entra na interface com os arquivos atuais"
    else 
        echo "ERRO : Não há dados baixados"
        echo "Para baixar os dados antes de gerar as estátísticas, use:"
        echo "./ep2_servico156.sh <nome do arquivo com URLs de dados do Serviço 156>"
    fi

fi









 