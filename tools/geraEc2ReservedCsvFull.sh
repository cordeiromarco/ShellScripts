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

echo "Gerando Lista de Instancias em CSV de todos os Clientes"

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

#gera arquivo executavel com comando AWS para listar EC2 em formato texto e salvar em arquivo csv
echo aws ec2 describe-reserved-instances --output text --profile ${nomedown} --region us-east-1 \>\> inventario/EC2Reserved/ListaEC2Reserved_${nomedown}.csv >> inventario/EC2Reserved/tmp.sh

echo aws ec2 describe-reserved-instances --output text --profile ${nomedown} --region sa-east-1 \>\> inventario/EC2Reserved/ListaEC2Reserved_${nomedown}.csv  >> inventario/EC2Reserved/tmp.sh

echo >> inventario/EC2Reserved/tmp.sh
echo sed -i \'\:a\;N\;\$\!ba\;s/\\\nRECURRINGCHARGES/ /g\' inventario/EC2Reserved/ListaEC2Reserved_${nomedown}.csv >> inventario/EC2Reserved/tmp.sh
echo sed -i \'\:a\;N\;\$\!ba\;s/\\\nTAGS/\	TAGS /g\' inventario/EC2Reserved/ListaEC2Reserved_${nomedown}.csv >> inventario/EC2Reserved/tmp.sh
echo sed -i \'s/RESERVEDINSTANCES\	USD/\	USD/g\' inventario/EC2Reserved/ListaEC2Reserved_${nomedown}.csv >> inventario/EC2Reserved/tmp.sh
echo sed -i \'s/RESERVEDINSTANCES\	//g\' inventario/EC2Reserved/ListaEC2Reserved_${nomedown}.csv >> inventario/EC2Reserved/tmp.sh
echo sed -i \'s/TAGS/\	TAGS/g\' inventario/EC2Reserved/ListaEC2Reserved_${nomedown}.csv >> inventario/EC2Reserved/tmp.sh
echo sed -i \'s/TAGS//g\' inventario/EC2Reserved/ListaEC2Reserved_${nomedown}.csv >> inventario/EC2Reserved/tmp.sh
echo sed -i \'s/Hourly\	\	\ \	team/Hourly\	team/g\' inventario/EC2Reserved/ListaEC2Reserved_${nomedown}.csv >> inventario/EC2Reserved/tmp.sh
echo sed -i \'s/$/\	\	\	\	\	${idconta}\	${nomedown}/\' inventario/EC2Reserved/ListaEC2Reserved_${nomedown}.csv >> inventario/EC2Reserved/tmp.sh
echo sed -i \'/Hourly/{s/\	\	\	\	\	${idconta}/\	\	\	${idconta}/g\;\:a\}\' inventario/EC2Reserved/ListaEC2Reserved_${nomedown}.csv  >> inventario/EC2Reserved/tmp.sh
echo sed -i \'/team/{s/\	\	\	/\	/g\;\:a\}\' inventario/EC2Reserved/ListaEC2Reserved_${nomedown}.csv >> inventario/EC2Reserved/tmp.sh
echo sed -i \"s/${idconta}/\\\'${idconta}/g\" inventario/EC2Reserved/ListaEC2Reserved_${nomedown}.csv >> inventario/EC2Reserved/tmp.sh
echo sed -i \'s/reserva\	\	\	/reserva\	/g\' inventario/EC2Reserved/ListaEC2Reserved_${nomedown}.csv >> inventario/EC2Reserved/tmp.sh
echo >> inventario/EC2Reserved/tmp.sh


done

sed -i 's/ .csv/.csv/g' inventario/EC2Reserved/tmp.sh


chmod +x inventario/EC2Reserved/tmp.sh

inventario/EC2Reserved/tmp.sh | pv -t

find . -empty -type f -exec rm {} \;

rm inventario/EC2Reserved/tmp.sh
rm tmpconta tmpid tmpawk
cat inventario/EC2Reserved/*.csv > inventario/EC2Reserved/ListaEC2Reserved.csv

sed -i "1s/^/AvailabilityZone	CurrencyCode	Duration	End	FixedPrice	InstanceCount	InstanceTenancy	InstanceType	OfferingClass	OfferingType	ProductDescription	ReservedInstancesId	Scope	Start	State	UsagePrice	Amount	Frequency	Key	Value	ID	CONTA\n/" inventario/EC2Reserved/ListaEC2Reserved.csv

