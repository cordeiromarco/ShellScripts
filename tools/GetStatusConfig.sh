#!/bin/bash

###função para listar Clientes e Região###
echo -e "\nPara ver a lista de Regiões execute o script com parametro '-r' para ver a lista de Clientes execute com '-c' e '-a' para listar amabos \n "


while getopts ':cra' option; do
  case "$option" in
    c) cat ../listas/ListaClientes.txt
       exit
       ;;
    r) cat ../listas/ListaRegiao.txt
       exit
       ;;
    a) cat ../listas/ListaRegiao.txt
       echo -e "\n"
       cat ../listas/ListaClientes.txt
       exit
       ;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done
shift $((OPTIND - 1))
###Fim da função para listar Clientes e Região###

rm inventario/StatusConfig/*

echo "Gerando GetStatusConfig em CSV de todos os Clientes"

awk '{print $1}' ../listas/contas.txt > tmpconta

declare -a nome

# Carrega lista de variaveis com os nomes de clientes
readarray nome < tmpconta

for ((i=0; i < ${#nome[@]}; i++)); do
nomedown=${nome[i],,}


echo awk  \'\$1 == \"$nomedown\" {print \$NF}\' ../listas/contas.txt \> tmpid > tmpawk
sed -i 's/ "/"/g' tmpawk

chmod +x tmpawk
./tmpawk
idconta=$(<tmpid)


#gera arquivo executavel com comando AWS para listar STATUS CONFIG  em formato texto e salvar em arquivo TXT
echo aws configservice get-status --profile ${nomedown} --region us-east-1  \>\> inventario/StatusConfig/StatusConfig_${nomedown}.txt >> inventario/StatusConfig/getstatusconfigtmp.sh
echo aws configservice get-status --profile ${nomedown} --region sa-east-1  \>\> inventario/StatusConfig/StatusConfig_${nomedown}.txt >> inventario/StatusConfig/getstatusconfigtmp.sh


echo >> inventario/StatusConfig/getstatusconfigtmp.sh
echo sed -i \'1s/^/CONTA:${nomedown} - ID:${idconta}\\n\\n/\' inventario/StatusConfig/StatusConfig_${nomedown}.txt >> inventario/StatusConfig/getstatusconfigtmp.sh
echo sed -i \'1s/^/*************************************\\n/\' inventario/StatusConfig/StatusConfig_${nomedown}.txt >> inventario/StatusConfig/getstatusconfigtmp.sh
echo >> inventario/StatusConfig/getstatusconfigtmp.sh

done

sed -i 's/ .txt/.txt/g' inventario/StatusConfig/getstatusconfigtmp.sh

chmod +x inventario/StatusConfig/getstatusconfigtmp.sh

inventario/StatusConfig/getstatusconfigtmp.sh | pv -t

find . -empty -type f -exec rm {} \;

#rm inventario/StatusConfig/getstatusconfigtmp.sh
rm tmpconta tmpawk tmpid


cat inventario/StatusConfig/*.txt > inventario/StatusConfig/StatusConfig.txt
