#!/bin/sh

echo "#Alarmes UnHealthyHostCount" >> funcao


for ((i=0; i < ${#ListNameELB[@]}; i++)); do
#Verifica se já existe alarme UnHealthyHostCount nas ELBs
aws cloudwatch describe-alarms-for-metric \
--profile ${conta} --region ${region} \
--metric-name UnHealthyHostCount \
--namespace AWS/ELB \
--dimensions Name=LoadBalancerName,Value=${ListNameELB[i]}\
--output table > UHealthyHosttmp 

grep -o UnHealthyHostCount UHealthyHosttmp > UHealthyHost

UHealthyHost=$(<UHealthyHost)

if [ -z "${UHealthyHost}" ]; then
#Gera script para criar o alarme
#Função AWS CLI para criar alarme(UnHealthyHostCount) nas ELBs

echo Gerando função AWS CLI UnHealthyHostCount para a ELB ${ListNameELB[i]}

echo aws cloudwatch put-metric-alarm \
--profile $conta --region $region \
--alarm-name ${contaupper}-${ListNameELB[i]}-UnHealthyHostCount \
--metric-name UnHealthyHostCount \
--namespace AWS/ELB \
--period 300 \
--threshold 0 \
--comparison-operator GreaterThanThreshold  \
--dimensions Name=LoadBalancerName,Value=${ListNameELB[i]} \
--evaluation-periods 2 \
--statistic Maximum \
--alarm-description  \"Created from CLI\" \
--ok-actions "$topiccloudwatch" \
--alarm-actions "$topiccloudwatch" >> funcao

else
	#ignora o script caso já existe e informa qual ELB já possui o alarme HealthyHostCount
        echo ELB ${ListNameELB[i]} já possui o alarme UnHealthyHostCount
fi

done

sed -i 's/ -UnHealthyHostCount/-UnHealthyHostCount/g' funcao
echo >> funcao

echo -e "Funções AWS CLI HealthyHostCount criadas com sucesso \n"

