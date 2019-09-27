#!/bin/sh
echo -e "Listando ID das instancias\n"

aws ec2 describe-instances  \
--profile $conta --region $region \
--query "Reservations[].Instances[].[InstanceId]" --output text > ListaEC2.txt
sleep 2
#declarando array de id dass instancias
declare -a instanceid

# Carrega lista de variaveis com os IDs gerados com a função AWS CLI acima
readarray instanceid < ListaEC2.txt
