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

rm inventario/RDS/*

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


#gera arquivo executavel com comando AWS para listar RDS em formato texto e salvar em arquivo csv
echo aws rds describe-db-instances --output text --profile ${nomedown} --region us-east-1 --query \'DBInstances[].[AllocatedStorage,AutoMinorVersionUpgrade,AvailabilityZone,BackupRetentionPeriod,CACertificateIdentifier,CopyTagsToSnapshot,DBClusterIdentifier,DBInstanceArn,DBInstanceClass,DBInstanceIdentifier,DBInstanceStatus,DBName,DbInstancePort,DbiResourceId,DeletionProtection,Engine,EngineVersion,IAMDatabaseAuthenticationEnabled,InstanceCreateTime,LatestRestorableTime,LicenseModel,MasterUsername,MonitoringInterval,MultiAZ,PerformanceInsightsEnabled,PreferredBackupWindow,PreferredMaintenanceWindow,PromotionTierPubliclyAccessible,StorageEncrypted,StorageType]\' \>\> inventario/RDS/ListaRDS_${nomedown}.csv >> inventario/RDS/tmp.sh

echo aws rds describe-db-instances --output text --profile ${nomedown} --region sa-east-1 --query \'DBInstances[].[AllocatedStorage,AutoMinorVersionUpgrade,AvailabilityZone,BackupRetentionPeriod,CACertificateIdentifier,CopyTagsToSnapshot,DBClusterIdentifier,DBInstanceArn,DBInstanceClass,DBInstanceIdentifier,DBInstanceStatus,DBName,DbInstancePort,DbiResourceId,DeletionProtection,Engine,EngineVersion,IAMDatabaseAuthenticationEnabled,InstanceCreateTime,LatestRestorableTime,LicenseModel,MasterUsername,MonitoringInterval,MultiAZ,PerformanceInsightsEnabled,PreferredBackupWindow,PreferredMaintenanceWindow,PromotionTierPubliclyAccessible,StorageEncrypted,StorageType]\' \>\> inventario/RDS/ListaRDS_${nomedown}.csv >> inventario/RDS/tmp.sh

echo >> inventario/RDS/tmp.sh
echo sed -i \'s/^/${idconta}\	${nomedown}\	/\' inventario/RDS/ListaRDS_${nomedown}.csv >> inventario/RDS/tmp.sh
echo sed -i \"s/${idconta}/\\\'${idconta}/g\" inventario/RDS/ListaRDS_${nomedown}.csv >> inventario/RDS/tmp.sh
echo >> inventario/RDS/tmp.sh


done

sed -i 's/ .csv/.csv/g' inventario/RDS/tmp.sh

chmod +x inventario/RDS/tmp.sh

inventario/RDS/tmp.sh | pv -t

find . -empty -type f -exec rm {} \;

rm inventario/RDS/tmp.sh
rm tmpconta tmpawk tmpid

#sed -i 's/,//g' inventario/RDS/ListaRDS_medgrupo.csv

cat inventario/RDS/*.csv > inventario/RDS/ListaRDS.csv

sed -i "1s/^/ID	CONTA	AllocatedStorage	AutoMinorVersionUpgrade	AvailabilityZone	BackupRetentionPeriod	CACertificateIdentifier	CopyTagsToSnapshot	DBClusterIdentifier	DBInstanceArn	DBInstanceClass	DBInstanceIdentifier	DBInstanceStatus	DBName	DbInstancePort	DbiResourceId	DeletionProtection	Engine	EngineVersion	IAMDatabaseAuthenticationEnabled	InstanceCreateTime	LatestRestorableTime	LicenseModel	MasterUsername	MonitoringInterval	MultiAZ	PerformanceInsightsEnabled	PreferredBackupWindow	PreferredMaintenanceWindow	PromotionTierPubliclyAccessible	StorageEncrypted	StorageType\n/" inventario/RDS/ListaRDS.csv
