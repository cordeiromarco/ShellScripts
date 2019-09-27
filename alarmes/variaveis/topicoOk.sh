#!/bin/sh


#Verifica se Topico Ipsense OK existe
 echo -e "Verificando se o topico SNS Ipsense OK existe\n"
 aws sns list-topics --output text --profile ${conta} --region ${region} > topicos.txt
 sed -n '/ok/I{p;q;}' topicos.txt > topicok.txt
 topicok=$(<topicok.txt)
 sleep 2

 if [ -z "${topicok}" ]; then
 echo -e "Criando o topico Ipsense Ok\n"
 aws sns create-topic --name ipsenseOk --profile ${conta} --region ${region} --output text
 topiciok=arn:aws:sns:$region:$idconta:ipsenseOk
 sleep 2
 else
 echo -e "O Topico SNS Ipsense Ok já existe\n"
 awk '/'TOPICS'/{print $NF}' topicok.txt > tmptopicok.txt
 topiciok=$(<tmptopicok.txt)
 sleep 2
 fi


rm  topicok.txt  topicos.txt
