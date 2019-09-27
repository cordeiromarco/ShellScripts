#!/bin/bash

LOG=/home/fedora/log/geraEc2CsvFullVol_$(date +%d%m%Y).out
exec 1>>${LOG}
exec 2>&1
echo "[`date`] ==== Inicio de rotina..."

###função para listar Clientes e Região###
. /home/fedora/scripts/alarmes/variaveis/Help.sh
###Fim da função para listar Clientes e Região###

rm /home/fedora/scripts/tools/inventario/EC2/*

echo "Gerando Lista de Instancias em CSV de todos os Clientes"

awk '{print $1}' /home/fedora/scripts/listas/contas.txt > tmpconta

declare -a nome

# Carrega lista de variaveis com os nomes de clientes
readarray nome < tmpconta

for ((i=0; i < ${#nome[@]}; i++)); do
nomedown=${nome[i],,}


echo awk  \'\$1 == \"$nomedown\" {print \$NF}\' /home/fedora/scripts/listas/contas.txt \> tmpid > tmpawk
sed -i 's/ "/"/g' tmpawk

chmod +x tmpawk
./tmpawk
idconta=$(<tmpid)


#gera arquivo executavel com comando AWS para listar EC2 em formato texto e salvar em arquivo csv
echo "echo  \*\*\*\*\*\*\* ${nomedown} " >> /home/fedora/scripts/tools/inventario/EC2/tmp.sh
echo aws ec2 describe-instances --output text --profile ${nomedown} --region us-east-1 --query \'Reservations[*].Instances[*].{Monitoring:Monitoring.State,HibernationOptions:HibernationOptions.Configured,CapacityReservationPreference:CapacityReservationSpecification.CapacityReservationPreference,ThreadsPerCore:CpuOptions.ThreadsPerCore,CoreCount:CpuOptions.CoreCount,AmiLaunchIndex:AmiLaunchIndex,Architecture:Architecture,ClientToken:ClientToken,EbsOptimized:EbsOptimized,EnaSupport:EnaSupport,Hypervisor:Hypervisor,ImageId:ImageId,InstanceId:InstanceId,InstanceType:InstanceType,KeyName:KeyName,LaunchTime:LaunchTime,PrivateDnsName:PrivateDnsName,PrivateIpAddress:PrivateIpAddress,PublicDnsName:PublicDnsName,PublicIpAddress:PublicIpAddress,RootDeviceName:RootDeviceName,RootDeviceType:RootDeviceType,SourceDestCheck:SourceDestCheck,StateTransitionReason:StateTransitionReason,SubnetId:SubnetId,VirtualizationType:VirtualizationType,VpcId:VpcId,STATUS:State.Name,StateCode:State.Code, AvailabilityZone:Placement.AvailabilityZone, PLATAFOM:Platform, NAME:[Tags[?Key==\`Name\`].Value] [0][0],VolumeId:BlockDeviceMappings[*].Ebs.VolumeId}\' \>\> /home/fedora/scripts/tools/inventario/EC2/ListaEC2_${nomedown}.csv >> /home/fedora/scripts/tools/inventario/EC2/tmp.sh

echo aws ec2 describe-instances --output text --profile ${nomedown} --region sa-east-1 --query \'Reservations[*].Instances[*].{Monitoring:Monitoring.State,HibernationOptions:HibernationOptions.Configured,CapacityReservationPreference:CapacityReservationSpecification.CapacityReservationPreference,ThreadsPerCore:CpuOptions.ThreadsPerCore,CoreCount:CpuOptions.CoreCount,AmiLaunchIndex:AmiLaunchIndex,Architecture:Architecture,ClientToken:ClientToken,EbsOptimized:EbsOptimized,EnaSupport:EnaSupport,Hypervisor:Hypervisor,ImageId:ImageId,InstanceId:InstanceId,InstanceType:InstanceType,KeyName:KeyName,LaunchTime:LaunchTime,PrivateDnsName:PrivateDnsName,PrivateIpAddress:PrivateIpAddress,PublicDnsName:PublicDnsName,PublicIpAddress:PublicIpAddress,RootDeviceName:RootDeviceName,RootDeviceType:RootDeviceType,SourceDestCheck:SourceDestCheck,StateTransitionReason:StateTransitionReason,SubnetId:SubnetId,VirtualizationType:VirtualizationType,VpcId:VpcId,STATUS:State.Name,StateCode:State.Code, AvailabilityZone:Placement.AvailabilityZone, PLATAFOM:Platform, NAME:[Tags[?Key==\`Name\`].Value] [0][0],VolumeId:BlockDeviceMappings[*].Ebs.VolumeId}\' \>\> /home/fedora/scripts/tools/inventario/EC2/ListaEC2_${nomedown}.csv  >> /home/fedora/scripts/tools/inventario/EC2/tmp.sh

echo >> /home/fedora/scripts/tools/inventario/EC2/tmp.sh
echo sed -i \'\:a\;N\;\$\!ba\;s/\\\nVOLUMEID/ /g\' /home/fedora/scripts/tools/inventario/EC2/ListaEC2_${nomedown}.csv >> /home/fedora/scripts/tools/inventario/EC2/tmp.sh
echo sed -i \'s/^/${idconta}\	${nomedown}\	/\' /home/fedora/scripts/tools/inventario/EC2/ListaEC2_${nomedown}.csv >> /home/fedora/scripts/tools/inventario/EC2/tmp.sh
echo sed -i \"s/${idconta}/\\\'${idconta}/g\" /home/fedora/scripts/tools/inventario/EC2/ListaEC2_${nomedown}.csv >> /home/fedora/scripts/tools/inventario/EC2/tmp.sh
echo >> /home/fedora/scripts/tools/inventario/EC2/tmp.sh


done

sed -i 's/ .csv/.csv/g' /home/fedora/scripts/tools/inventario/EC2/tmp.sh

chmod +x /home/fedora/scripts/tools/inventario/EC2/tmp.sh

/home/fedora/scripts/tools/inventario/EC2/tmp.sh | pv -t

find /home/fedora/scripts/tools/inventario/EC2/ -empty -type f -exec rm {} \;

rm /home/fedora/scripts/tools/inventario/EC2/tmp.sh
rm tmpconta tmpawk tmpid

sed -i 's/,//g' /home/fedora/scripts/tools/inventario/EC2/ListaEC2_medgrupo.csv

cat /home/fedora/scripts/tools/inventario/EC2/*.csv > /home/fedora/scripts/tools/inventario/EC2/ListaEC2.csv

sed -i "1s/^/ID	CONTA	AmiLaunchIndex	Architecture	AvailabilityZone	CapacityReservationPreference	ClientToken	CoreCount	EbsOptimized	EnaSupport	HibernationOptions	Hypervisor	ImageId	InstanceId	InstanceType	KeyName	LaunchTime	Monitoring	NAME	PLATAFOM	PrivateDnsName	PrivateIpAddress	PublicDnsName	PublicIpAddress	RootDeviceName	RootDeviceType	STATUS	SourceDestCheck	StateCode       StateTransitionReason	SubnetId	ThreadsPerCore	VirtualizationType	VpcId	Volume ID\n/" /home/fedora/scripts/tools/inventario/EC2/ListaEC2.csv


echo "[`date`] ==== Fim de rotina..."

