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
echo aws ec2 describe-instances --output text --profile ${nomedown} --region us-east-1 --query \'Reservations[*].Instances[*].{Monitoring:Monitoring.State,HibernationOptions:HibernationOptions.Configured,CapacityReservationPreference:CapacityReservationSpecification.CapacityReservationPreference,ThreadsPerCore:CpuOptions.ThreadsPerCore,CoreCount:CpuOptions.CoreCount,AmiLaunchIndex:AmiLaunchIndex,Architecture:Architecture,ClientToken:ClientToken,EbsOptimized:EbsOptimized,EnaSupport:EnaSupport,Hypervisor:Hypervisor,ImageId:ImageId,InstanceId:InstanceId,InstanceType:InstanceType,KeyName:KeyName,LaunchTime:LaunchTime,PrivateDnsName:PrivateDnsName,PrivateIpAddress:PrivateIpAddress,PublicDnsName:PublicDnsName,PublicIpAddress:PublicIpAddress,RootDeviceName:RootDeviceName,RootDeviceType:RootDeviceType,SourceDestCheck:SourceDestCheck,StateTransitionReason:StateTransitionReason,SubnetId:SubnetId,VirtualizationType:VirtualizationType,VpcId:VpcId,STATUS:State.Name,StateCode:State.Code, AvailabilityZone:Placement.AvailabilityZone, PLATAFOM:Platform, NAME:[Tags[?Key==\`Name\`].Value] [0][0]}\' \>\> inventario/EC2/ListaEC2_${nomedown}.csv >> inventario/EC2/tmp.sh

echo aws ec2 describe-instances --output text --profile ${nomedown} --region sa-east-1 --query \'Reservations[*].Instances[*].{Monitoring:Monitoring.State,HibernationOptions:HibernationOptions.Configured,CapacityReservationPreference:CapacityReservationSpecification.CapacityReservationPreference,ThreadsPerCore:CpuOptions.ThreadsPerCore,CoreCount:CpuOptions.CoreCount,AmiLaunchIndex:AmiLaunchIndex,Architecture:Architecture,ClientToken:ClientToken,EbsOptimized:EbsOptimized,EnaSupport:EnaSupport,Hypervisor:Hypervisor,ImageId:ImageId,InstanceId:InstanceId,InstanceType:InstanceType,KeyName:KeyName,LaunchTime:LaunchTime,PrivateDnsName:PrivateDnsName,PrivateIpAddress:PrivateIpAddress,PublicDnsName:PublicDnsName,PublicIpAddress:PublicIpAddress,RootDeviceName:RootDeviceName,RootDeviceType:RootDeviceType,SourceDestCheck:SourceDestCheck,StateTransitionReason:StateTransitionReason,SubnetId:SubnetId,VirtualizationType:VirtualizationType,VpcId:VpcId,STATUS:State.Name,StateCode:State.Code, AvailabilityZone:Placement.AvailabilityZone, PLATAFOM:Platform, NAME:[Tags[?Key==\`Name\`].Value] [0][0]}\' \>\> inventario/EC2/ListaEC2_${nomedown}.csv  >> inventario/EC2/tmp.sh

echo >> inventario/EC2/tmp.sh
echo sed -i \'s/^/${idconta}\	${nomedown}\	/\' inventario/EC2/ListaEC2_${nomedown}.csv >> inventario/EC2/tmp.sh
echo sed -i \"s/${idconta}/\\\'${idconta}/g\" inventario/EC2/ListaEC2_${nomedown}.csv >> inventario/EC2/tmp.sh
echo >> inventario/EC2/tmp.sh


done

sed -i 's/ .csv/.csv/g' inventario/EC2/tmp.sh

chmod +x inventario/EC2/tmp.sh

inventario/EC2/tmp.sh | pv -t

find . -empty -type f -exec rm {} \;

rm inventario/EC2/tmp.sh
rm tmpconta tmpawk tmpid

sed -i 's/,//g' inventario/EC2/ListaEC2_medgrupo.csv

cat inventario/EC2/*.csv > inventario/EC2/ListaEC2.csv

sed -i "1s/^/ID	CONTA	AmiLaunchIndex	Architecture	AvailabilityZone	CapacityReservationPreference	ClientToken	CoreCount	EbsOptimized	EnaSupport	HibernationOptions	Hypervisor	ImageId	InstanceId	InstanceType	KeyName	LaunchTime	Monitoring	NAME	PLATAFOM	PrivateDnsName	PrivateIpAddress	PublicDnsName	PublicIpAddress	RootDeviceName	RootDeviceType	STATUS	SourceDestCheck	StateCode       StateTransitionReason	SubnetId	ThreadsPerCore	VirtualizationType	VpcId\n/" inventario/EC2/ListaEC2.csv
