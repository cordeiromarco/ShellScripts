#!/bin/bash


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

echo -e "Função inserir regra no SG\n"

read -p "Digite a conta que deseja fazer a consulta[default]: " conta

if [ -z "${conta}" ]; then
    FOO=${conta:=default}
else
    FOO=${conta}
fi

read -p "Digite a Região que deseja fazer a consulta[us-east-1]: " region

if [ -z "${region}" ]; then
    FOO=${region:=us-east-1}
else
    FOO=${region}
fi

#List EC2 Instance

aws ec2 describe-instances \
--output table \
--profile ${conta} \
--region ${region} \
--query 'Reservations[*].Instances[*].{PublicIpAddress:PublicIpAddress, ID:InstanceId, NAME:[Tags[?Key==`Name`].Value] [0][0] }'


read -p "Escolha a ID da instancia que deseja adicionar uma regra de SG: " id

declare -a sg
declare -a sgname

readarray sg < <(aws ec2 describe-instances --output text --profile ${conta} --region ${region} --instance-id ${id} --query 'Reservations[*].Instances[*].[SecurityGroups]' | awk '{print $1}')
readarray sgname < <(aws ec2 describe-instances --output text --profile ${conta} --region ${region} --instance-id ${id} --query 'Reservations[*].Instances[*].[SecurityGroups]' | awk '{print $2}')


for ((i=0; i < ${#sg[@]}; i++)); do

echo Inbounds do SG ${sgname[i]} ID ${sg[i]}:
aws ec2 describe-security-groups --group-ids ${sg[i]} --profile ${conta} --region ${region} --output text --query 'SecurityGroups[*].{IpPermissions:IpPermissions}' | grep 'IPRANGES\|USERIDGROUPPAIRS' --color

var="$(aws ec2 describe-security-groups --group-ids ${sg[i]} --output text --profile ${conta} --region ${region} --query 'SecurityGroups[*].{IpPermissions:IpPermissions}' | grep 'IPRANGES\|USERIDGROUPPAIRS' | wc -l )"

echo Número de Inbounds no SG ${sgname[i]} ID ${sg[i]}: ${var}
echo
done


read -p "Escolha o ID do SG que deseja adionar a regra: " sgid
echo
read -p "Digite a Porta: " port
echo
read -p "Digite o IP: " ip
echo
read -p "Escolha o protocolo desejado TCP | UDP | ICMP: " protocol
echo
read -p "Insira uma Descrição: " descricao

echo "aws ec2 authorize-security-group-ingress --profile ${conta} --region ${region} --group-id ${sgid} --ip-permissions IpProtocol=${protocol},FromPort=${port},ToPort=${port},IpRanges='[{CidrIp=${ip},Description=\"${descricao}\"}]'" > insereregrasg.sh

chmod +x insereregrasg.sh
./insereregrasg.sh
#rm insereregrasg.sh


aws ec2 describe-security-groups --group-ids ${sgid} --output text --profile ${conta} --region ${region} --query 'SecurityGroups[*].{IpPermissions:IpPermissions}' | grep 'IPRANGES\|USERIDGROUPPAIRS' --color
numeroatual="$(aws ec2 describe-security-groups --group-ids ${sgid} --output text --profile ${conta} --region ${region} --query 'SecurityGroups[*].{IpPermissions:IpPermissions}' | grep 'IPRANGES\|USERIDGROUPPAIRS' | wc -l)"
echo Número de Inbounds atual: ${numeroatual}/60


