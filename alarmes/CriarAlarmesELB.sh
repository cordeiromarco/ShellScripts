#!/bin/sh
. ./variaveis/Help.sh

. ./variaveis/AssumeRole.sh
. ./variaveis/topico24hs.sh
. ./variaveis/topicocloudwatch.sh
. ./variaveis/ListarELB.sh
#Topico 24hs
echo -e "Verificando se já existe alarme HealthyHostCount\n"
. ./variaveis/VerificarHealthyHostCount.sh
sleep 2
#Topico CloudWatch
echo -e "Verificando se já existe alarme UnHealthyHostCount\n"
. ./variaveis/VerificarUnHealthyHostCount.sh

chmod +x funcao

echo -e "Executando funções AWS CLI de criação de Alarmes HealthyHostCount e UnHealthyHostCount\n"
./funcao

rm ListNameELB HealthyHost HealthyHosttmp UHealthyHost UHealthyHosttmp funcao
