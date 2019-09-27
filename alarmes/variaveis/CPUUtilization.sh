#!/bin/sh

#inicia o loop com as variaveis do arquivo de DBInstanceIdentifier
#Criando Alarme CPUUtilization
echo -e "Verificando se já existe alarme CPUUtilization nas RDS\n"
sleep 2

for ((i=0; i < ${#ListDBInstanceIdentifier[@]}; i++)); do

#Verifica se já existe alarme  CPUUtilization nas RDS
aws cloudwatch describe-alarms-for-metric \
--profile ${conta} \
--region ${region}  \
--metric-name CPUUtilization \
--namespace AWS/RDS \
--dimensions Name=DBInstanceIdentifier,Value=${ListDBInstanceIdentifier[i]} \
--output table > describealarms
grep -o CPUUtilization describealarms > CPUUtilization

cpuutilization=$(<CPUUtilization)

if [ -z "${cpuutilization}" ]; then
#Gera script para criar o alarme
#Função AWS CLI para criar alarme(CPUUtilization) na RDS
echo Gerando função AWS CLI CPUUtilization para o DBInstanceIdentifier ${ListDBInstanceIdentifier[i]}

echo aws cloudwatch put-metric-alarm \
--profile $conta \
--region $region  \
--alarm-name ${contaupper}-${ListDBInstanceIdentifier[i]}-High-CPU-Utilization \
--alarm-description \"CPU Usage \>=90% for 10 minutes\" \
--metric-name CPUUtilization \
--namespace AWS/RDS \
--statistic Minimum \
--period 300 \
--threshold 90 \
--comparison-operator GreaterThanOrEqualToThreshold \
--dimensions Name=DBInstanceIdentifier,Value=${ListDBInstanceIdentifier[i]} \
--evaluation-periods 2 \
--unit Percent \
--alarm-actions $topicCloudwatch \
--ok-actions $topicCloudwatch >> AlarmeCPUUtilization.sh

else
   #ignora o script caso já existe e informa qual ID já possui o alarme StatusCheckFailed_Instance
    echo RDS ${ListDBInstanceIdentifier[i]} já possui o alarme CPUUtilization
    echo
fi

done

sed -i 's/ -High-CPU-Utilization/-High-CPU-Utilization/g' AlarmeCPUUtilization.sh

echo

echo -e "Funções AWS CLI CPUUtilization criadas com sucesso \n"


