#!/bin/sh

#Verifica se Topico Ipsense  24H existe
echo -e "Verificando se o topico SNS CloudWatch existe\n"
aws sns list-topics --output text --profile $conta --region $region > topicos
sed -n '/cloudwatch/I{p;q;}' topicos > topiccloudwatch
topiccloudwatch=$(<topiccloudwatch)

if [ -z "${topiccloudwatch}" ]; then
echo -e "Criando o topico CloudWatch\n"
aws sns create-topic --name CloudWatch  --profile ${conta} --region ${region} --output text
aws sns subscribe --output text --profile ${conta} --region ${region} --topic-arn arn:aws:sns:$region:$idconta:CloudWatch --protocol HTTPS --notification-endpoint https://events.pagerduty.com/adapter/cloudwatch_sns/v1/e88a2d84897e4e11892a05fcd2831027
topiccloudwatch=arn:aws:sns:$region:$idconta:CloudWatch
sleep 2
else
echo -e "O Topico SNS CloudWatch já existe\n"
awk '/'TOPICS'/{print $NF}' topiccloudwatch > tmptopiccloudwatch
topiccloudwatch=$(<tmptopiccloudwatch)
fi
rm tmptopiccloudwatch topiccloudwatch topicos

