#!/bin/bash

LOG=/home/fedora/log/listaccounts_$(date +%d%m%Y).out
exec 1>>${LOG}
exec 2>&1
echo "[`date`] ==== Inicio de rotina..."


HOME="/home/fedora/"
AWS_CONFIG_FILE="~/.aws/config"
/home/fedora/.local/bin/aws organizations list-accounts --output text > /home/fedora/scripts/accounts/ListAccounts.csv


sed -i "s/.com.br	/.com.br	\'/g" /home/fedora/scripts/accounts/ListAccounts.csv
sed -i "s/.com	/.com	'/g" /home/fedora/scripts/accounts/ListAccounts.csv
sed -i 's/ACCOUNTS	/''/g' /home/fedora/scripts/accounts/ListAccounts.csv
sed -i "1s/^/ARN	Email	Id	JoinedMethod	JoinedTimestamp	Name	Status\n/" /home/fedora/scripts/accounts/ListAccounts.csv



/home/fedora/.local/bin/aws s3 cp /home/fedora/scripts/accounts/ListAccounts.csv s3://list-accounts/


echo "[`date`] ==== Fim de rotina..."

