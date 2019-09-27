#!/bin/sh
#Executa o script de help Conta e Região
. ./variaveis/Help.sh

#Cria diretório de terraform e git

echo -e "Gerando diretórios\n"
mkdir terracodecommit
mkdir terracodecommit/git

#Assume role da conta origem
. ./variaveis/AssumeRole.sh

echo -e "Gerando Lista de Repositorios do Code Commit\n"
. ./variaveis/GeraListaRepoCodeCommit.sh
sleep 4

echo -e "Criando Terraform baseado na lsita acima\n"
. ./variaveis/CriaTerraformCodeCommit.sh
sleep 4

echo -e "Gerando script Git Clone\n"
sleep 4
. ./variaveis/GetID.sh
. ./variaveis/GetCredGit.sh
. ./variaveis/GeraUrlGitClone.sh

#Assum conta destino
echo -e "Asumindo role da conta Destino\n"
. ./variaveis/AssumeRole.sh

echo -e "Gerando provider.tf da conta Destino\n"
sleep 4
. ./variaveis/GetID.sh
. ./variaveis/GetARN.sh
. ./variaveis/GeraProviderTf.sh

#Gera  script Git Push
echo -e "Gerando script Git Clone\n"
sleep 4
. ./variaveis/GetCredGit.sh
. ./variaveis/GeraUrlGitPush.sh

#move arquivos
echo -e "Movendo arquivos\n"
sleep 2
mv provider.tf CodeCommit.tf terracodecommit/
mv UrlGitPush.sh UrlGitClone.sh terracodecommit/git

#apaga arquivos de variaveis
echo -e "Apagando variaveis\n"
sleep 2
rm codecommit arn ID* pass user

#Inicia e aplica configurações do terraform

cd terracodecommit
echo -e "Iniciando Terraform\n"
terraform init
echo -e "Aplicando Terraform\n"
terraform apply -auto-approve


#Inicia copia de git

cd git/
echo -e "Executando Git Clone\n"
chmod +x *.sh
./UrlGitClone.sh

sleep 4
echo -e "Executando Git Push na conta destino \n"
./UrlGitPush.sh
