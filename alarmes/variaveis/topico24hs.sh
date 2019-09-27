#!/bin/sh

#Verifica se Topico Ipsense  24H existe
echo -e "Verificando se o topico SNS Ipsense 24H existe\n"
aws sns list-topics --output text --profile ${conta} --region ${region} > topicos.txt
sed -n '/24h/I{p;q;}' topicos.txt > topic24h.txt
topic=$(<topic24h.txt)
sleep 2

if [ -z "${topic}" ]; then
echo -e "Criando o topico Ipsense 24h\n"
aws sns create-topic --name ipsense24h --profile ${conta} --region ${region} --output text
aws sns subscribe --output text --profile ${conta} --region ${region} --topic-arn arn:aws:sns:$region:$idconta:ipsense24h --protocol HTTPS --notification-endpoint https://events.pagerduty.com/integration/dca9aa5cb33742eaaf91f144bb2c0800/enqueue
topic24h=arn:aws:sns:$region:$idconta:ipsense24h
sleep 2
else
echo -e "O Topico SNS Ipsense 24H já existe\n"
awk '/'TOPICS'/{print $NF}' topic24h.txt > tmptopic24.txt
topic24h=$(<tmptopic24.txt)
rm  tmptopic24.txt
sleep 2
fi


rm topic24h.txt topicos.txt
