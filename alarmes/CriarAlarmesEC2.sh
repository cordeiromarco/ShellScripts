#!/bin/sh
. ./variaveis/Help.sh

. ./variaveis/AssumeRole.sh
. ./variaveis/topico24hs.sh
. ./variaveis/topicoOk.sh

. ./variaveis/ListarEC2.sh
#Topico 24hs
. ./variaveis/StatusCheckFailed_Instance.sh
#Topico 24hs
. ./variaveis/StatusCheckFailed_System.sh


cat AlarmeStatusCheckFailed_System.sh AlarmeStatusCheckFailed_Instance.sh > Alarmes.sh

chmod +x Alarmes.sh
echo -e "Executando funções AWS CLI de criação de Alarmes StatusCheckFailed_Instance e AlarmeStatusCheckFailed_System\n"
./Alarmes.sh

rm AlarmeStatusCheckFailed_Instance.sh AlarmeStatusCheckFailed_System.sh describe-alarms.txt ListaEC2Running.txt ListaEC2.txt StatusCheckInstance.txt StatusCheckSystem.txt Alarmes.sh
