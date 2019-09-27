#!/bin/bash
###função para listar Clientes e Região###
. /home/fedora/scripts/tools/auto_add_sg.sh

. /home/fedora/scripts/tools/get_ip_por_id.sh
. /home/fedora/scripts/tools/get_key_por_id.sh

ssh -i "$CHAVES/$key.pem" root@$ip > user
cat user | awk '{print $6}' | sed s/\"//g > user2

#echo ssh -i \"$CHAVES\/$key.pem\" root@$ip

user=$(<user2)

ssh -i "$CHAVES/$key.pem" $user@$ip

#echo ssh -i \"$CHAVES\/$key.pem\" $user@$ip

rm user user2
