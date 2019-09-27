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

echo -e "Função criar Snapshot\n"

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
--query 'Reservations[*].Instances[*].{ID:InstanceId, NAME:[Tags[?Key==`Name`].Value] [0][0] }'


read -p "Escolha a ID que deseja gerar Snapshot: " id
echo
echo -e "Volumes disponíveis para Snapshot da instancia selecionada:\n"

aws ec2 describe-volumes \
--profile ${conta} \
--region ${region} \
--filters Name=attachment.instance-id,Values=${id} \
--output table \
--query 'Volumes[*].{ID:VolumeId,SIZE:Size,DEVICE:Attachments[0].Device}'

echo

read -p "Escolha o volume que deseja fazer Snapshot: " volumeid

read -p "Insira uma descrição: " description

aws ec2 create-snapshot \
--profile ${conta} \
--region ${region} \
--volume-id ${volumeid} \
--description ${description} \
--output table > tmp

aws ec2 describe-snapshots \
--profile ${conta} \
--region ${region} \
--filters Name=description,Values=${description} \
--output text \
--query 'Snapshots[*].SnapshotId' > snapshotid

snapshotid=$(<snapshotid)

aws ec2 create-tags \
--profile ${conta} \
--region ${region} \
--resources ${snapshotid} \
--tags Key=Name,Value=CLI_SnapShot_${description}


aws ec2 describe-snapshots \
--profile ${conta} \
--region ${region} \
--filters Name=description,Values=${description} \
--output table


rm tmp snapshotid
