#!/bin/sh

 #inicia o loop com as variaveis do arquivo de ListDBInstanceIdentifier
 #Criando Alarme FreeStorageSpace
 echo -e "Verificando se já existe alarme FreeStorageSpace nas RDS\n"
 sleep 2
 
 for ((i=0; i < ${#ListDBInstanceIdentifier[@]}; i++)); do
 
 #Verifica se já existe alarme  FreeStorageSpace nas RDS
 aws cloudwatch describe-alarms-for-metric \
 --profile ${conta} \
 --region ${region}  \
 --metric-name FreeStorageSpace \
 --namespace AWS/RDS \
 --dimensions Name=DBInstanceIdentifier,Value=${ListDBInstanceIdentifier[i]} \
 --output table > describealarms
 grep -o FreeStorageSpace describealarms > FreeStorageSpace
 
 freestoragespace=$(<FreeStorageSpace)
 
 if [ -z "${freestoragespace}" ]; then
 #Gera script para criar o alarme
 #Função AWS CLI para criar alarme(FreeStorageSpace) na RDS
 echo Gerando função AWS CLI FreeStorageSpace para o DBInstanceIdentifier ${ListDBInstanceIdentifier[i]}
 
 echo aws cloudwatch put-metric-alarm \
 --profile $conta \
 --region $region \
 --alarm-name ${contaupper}-${ListDBInstanceIdentifier[i]}-Low-Free-Storage-Space \
 --statistic Average \
 --alarm-description \"Disk less than 3GB\" \
 --metric-name FreeStorageSpace \
 --namespace AWS/RDS \
 --period 300 \
 --threshold 3145728000.0 \
 --comparison-operator LessThanThreshold \
 --dimensions Name=DBInstanceIdentifier,Value=${ListDBInstanceIdentifier[i]} \
 --evaluation-periods 1 \
 --alarm-actions $topic24h \
 --ok-actions $topicCloudwatch >> AlarmeFreeStorageSpace.sh
 
 else
    #ignora o script caso já existe e informa qual ID já possui o alarme StatusCheckFailed_Instance
     echo RDS ${ListDBInstanceIdentifier[i]} já possui o alarme FreeStorageSpace
     echo
 fi
 
 done
 
 sed -i 's/ -Low-Free-Storage-Space/-Low-Free-Storage-Space/g' AlarmeFreeStorageSpace.sh
 
 echo
 
 echo -e "Funções AWS CLI FreeStorageSpace criadas com sucesso \n"

