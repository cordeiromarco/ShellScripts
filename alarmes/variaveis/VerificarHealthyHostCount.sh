#!/bin/sh

echo "#Alarmes HealthyHostCount" >> funcao

for ((i=0; i < ${#ListNameELB[@]}; i++)); do
#Verifica se já existe alarme HealthyHostCount nas ELBs
aws cloudwatch describe-alarms-for-metric \
--profile ${conta} --region ${region} \
--metric-name HealthyHostCount \
--namespace AWS/ELB \
--dimensions Name=LoadBalancerName,Value=${ListNameELB[i]} \
--output table > HealthyHosttmp

grep -o HealthyHostCount HealthyHosttmp > HealthyHost

HealthyHost=$(<HealthyHost)

if [ -z "${HealthyHost}" ]; then
#Gera script para criar o alarme
#Função AWS CLI para criar alarme(HealthyHostCount) nas ELBs

echo Gerando função AWS CLI HealthyHostCount para a ELB ${ListNameELB[i]}

echo aws cloudwatch put-metric-alarm \
--profile $conta --region $region \
--alarm-name ${contaupper}-${ListNameELB[i]}-NoHealthyHost \
--metric-name HealthyHostCount \
--namespace AWS/ELB \
--period 60 \
--threshold 0 \
--comparison-operator LessThanOrEqualToThreshold  \
--dimensions Name=LoadBalancerName,Value=${ListNameELB[i]} \
--evaluation-periods 5 \
--datapoints-to-alarm 5 \
--statistic Average \
--alarm-description  \"Alerta de ELB Sem hosts funcionais\" \
--ok-actions "$topic24h" \
--alarm-actions "$topic24h" >> funcao

else
	#ignora o script caso já existe e informa qual ELB já possui o alarme HealthyHostCount
	echo ELB ${ListNameELB[i]} já possui o alarme HealthyHostCount
fi

done

sed -i 's/ -NoHealthyHost/-NoHealthyHost/g' funcao
echo >> funcao


echo -e "Funções AWS CLI HealthyHostCount criadas com sucesso \n"

