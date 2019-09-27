#!/bin/sh
####função AWS CLI para listar ID das instancias EC2 e salvar em um arquivo txt
echo -e "Listando DBInstanceIdentifier\n"

aws rds describe-db-instances \
--profile ${conta} \
--region ${region}  \
--output text \
--query 'DBInstances[].[DBInstanceIdentifier]' > ListDBInstanceIdentifier

sleep 2
#declarando array de DBInstanceIdentifier
declare -a ListDBInstanceIdentifier

# Carrega lista de variaveis com os DBInstanceIdentifier gerados com a função AWS CLI acima
readarray ListDBInstanceIdentifier < ListDBInstanceIdentifier

