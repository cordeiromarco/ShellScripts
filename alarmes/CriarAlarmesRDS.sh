#!/bin/sh
. ./variaveis/Help.sh

. ./variaveis/AssumeRole.sh
. ./variaveis/topico24hs.sh
. ./variaveis/topicocloudwatch.sh

echo -e "Iniciando processo de ciração de alarmes RDS na conta '${conta}'\n"

. ./variaveis/ListarRDS.sh

#Topico CloudWatch
. ./variaveis/CPUUtilization.sh
#Topico 24hs
. ./variaveis/FreeStorageSpace.sh


cat Alarme*.sh > Alarmes.sh

chmod +x Alarmes.sh
echo -e "Executando funções AWS CLI de criação de Alarmes FreeStorageSpace e CPUUtilization \n"
./Alarmes.sh

rm Alarme*.sh 
rm CPUUtilization  describealarms  tmp* ListDBInstanceIdentifier topic* FreeStorageSpace
