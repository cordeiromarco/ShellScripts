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

echo "Gerando inventario de snapshot"


declare -a nome

# Carrega lista de variaveis com os nomes de clientes
readarray nome < ../popularProfile/nome.txt
for ((i=0; i < ${#nome[@]}; i++)); do
nomedown=${nome[i],,}

#gera arquivo executavel com comando AWS para listar EC2 em formato texto e salvar em arquivo csv
echo aws events list-rules --profile ${nomedown} --region us-east-1 --output text \| grep \'Daily\\\|Retention\' \> inventario/snapshot/listSnapshot_${nomedown}_us-east-1.csv >> inventario/snapshot/tmp.sh
echo aws events list-rules --profile ${nomedown} --region sa-east-1 --output text \| grep \'Daily\\\|Retention\' \> inventario/snapshot/listSnapshot_${nomedown}_sa-east-1.csv >> inventario/snapshot/tmp.sh

done


sed -i 's/ _sa-east-1.csv/_sa-east-1.csv/g' inventario/snapshot/tmp.sh
sed -i 's/ _us-east-1.csv/_us-east-1.csv/g' inventario/snapshot/tmp.sh


chmod +x inventario/snapshot/tmp.sh

inventario/snapshot/tmp.sh | pv -t

find ./inventario/snapshot/ -empty -type f -exec rm {} \;

rm inventario/snapshot/tmp.sh

cat inventario/snapshot/*.csv > inventario/snapshot/listSnapshot.csv

