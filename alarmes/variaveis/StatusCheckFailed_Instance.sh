#!/bin/sh
#inicia o loop com as variaveis do arquivo de IDs
#Criando Alarme StatusCheckFailed_Instance
echo -e "Verificando se já existe alarme StatusCheckFailed_Instance nas instancias\n"
sleep 2

for ((i=0; i < ${#instanceid[@]}; i++)); do

#Verifica se já existe alarme StatusCheckFailed_Instance nas instancias
aws cloudwatch describe-alarms-for-metric \
--profile ${conta} --region ${region} \
--metric-name StatusCheckFailed_Instance \
--namespace AWS/EC2 \
--dimensions Name=InstanceId,Value=${instanceid[i]} \
--output table > describe-alarms.txt

grep -o StatusCheckFailed_Instance describe-alarms.txt > StatusCheckInstance.txt

statusinstances=$(<StatusCheckInstance.txt)


if [ -z "${statusinstances}" ]; then
#Gera script para criar o alarme
#Função AWS CLI para criar alarme(StatusCheckFailed_Instance) na Instancia EC2
echo Gerando função AWS CLI StatusCheckFailed_Instance para o ID ${instanceid[i]}
echo aws cloudwatch put-metric-alarm --profile $conta --region $region \
--alarm-name ${contaupper}-${instanceid[i]}-Status-Check-Failed-Instance \
--metric-name StatusCheckFailed_Instance \
--namespace AWS/EC2 \
--period 300 \
--threshold 0 \
--comparison-operator GreaterThanThreshold  \
--dimensions Name=InstanceId,Value=${instanceid[i]} \
--evaluation-periods 2 \
--statistic Minimum \
--ok-actions $topiciok \
--alarm-actions "$topic24h" "arn:aws:swf:$region:$idconta:action/actions/AWS_EC2.InstanceId.Reboot/1.0" >> AlarmeStatusCheckFailed_Instance.sh


else
   #ignora o script caso já existe e informa qual ID já possui o alarme StatusCheckFailed_Instance
    echo Instnacia ${instanceid[i]} já possui o alarme StatusCheckFailed_Instance
fi

done

echo

sed -i 's/ -Status-Check-Failed-Instance/-Status-Check-Failed-Instance/g' AlarmeStatusCheckFailed_Instance.sh
sed -i '1s/^/#StatusCheckFailed_Instance\n/' AlarmeStatusCheckFailed_Instance.sh

echo -e "Funções AWS CLI StatusCheckFailed_Instance criadas com sucesso \n"
