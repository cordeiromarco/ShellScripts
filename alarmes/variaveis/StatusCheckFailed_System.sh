#!/bin/sh
#####função AWS CLI para listar ID das instancias EC2 em modo Runing e salvar em um arquivo txt
aws ec2 describe-instances \
--filters Name=instance-state-name,Values=running \
--profile $conta --region $region \
--query "Reservations[].Instances[].[InstanceId]" \
--output text > ListaEC2Running.txt

#declarando array de id dass instancias running
declare -a instanceruning

# Carrega lista de variaveis com os IDs gerados com a função AWS CLI acima
readarray instanceruning < ListaEC2Running.txt

#inicia o loop com as variaveis do arquivo de IDs Running
#Criando Alarme StatusCheckFailed_System
echo -e "Verificando se já existe alarme StatusCheckFailed_System nas instancias\n"
sleep 2

for ((i=0; i < ${#instanceruning[@]}; i++)); do

#Verifica se já existe alarme StatusCheckFailed_System nas instancias
aws cloudwatch describe-alarms-for-metric \
--profile ${conta} --region ${region} \
--metric-name StatusCheckFailed_System \
--namespace AWS/EC2 \
--dimensions Name=InstanceId,Value=${instanceruning[i]} \
--output table > describe-alarms.txt

grep -o StatusCheckFailed_System describe-alarms.txt > StatusCheckSystem.txt

statussystem=$(<StatusCheckSystem.txt)

if [ -z "${statussystem}" ]; then

echo Gerando função AWS CLI StatusCheckFailed_System para o ID ${instanceruning[i]}
echo aws cloudwatch put-metric-alarm --profile $conta --region $region \
--alarm-name ${contaupper}-${instanceruning[i]}-Status-Check-Failed-System \
--metric-name StatusCheckFailed_System \
--namespace AWS/EC2 \
--period 60 \
--threshold 0 \
--comparison-operator GreaterThanThreshold  \
--dimensions Name=InstanceId,Value=${instanceruning[i]} \
--evaluation-periods 5 \
--statistic Minimum \
--ok-actions $topiciok \
--alarm-actions "$topic24h" "arn:aws:automate:$region:ec2:recover" >> AlarmeStatusCheckFailed_System.sh

else
   #ignora o script caso já existe e informa qual ID já possui o alarme StatusCheckFailed_System
    echo Instnacia ${instanceruning[i]} já possui o alarme StatusCheckFailed_System
fi

done


sed -i 's/ -Status-Check-Failed-System/-Status-Check-Failed-System/g' AlarmeStatusCheckFailed_System.sh
sed -i '1s/^/#StatusCheckFailed_System\n/' AlarmeStatusCheckFailed_System.sh

echo -e "Funções AWS CLI StatusCheckFailed_System criadas com sucesso \n"

