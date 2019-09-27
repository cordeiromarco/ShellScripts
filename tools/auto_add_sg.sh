#!/bin/sh
 
. /home/fedora/scripts/alarmes/variaveis/Help.sh

. /home/fedora/scripts/tools/get_conta_por_id.sh
. /home/fedora/scripts/tools/get_region_por_id.sh

aws ec2 describe-instances \
--output text \
--instance-id $1 \
--profile ${conta} --region ${region} \
--query 'Reservations[*].Instances[*].[SecurityGroups]' \
| awk '{print $1,$2}' | grep -i ipsense | awk '{print $1}' > sgid

sgid=$(<sgid)

port=22
ip=54.161.19.193/32
protocol=TCP
descricao=#IPsense_Automacao

echo "aws ec2 authorize-security-group-ingress \
--profile ${conta} --region ${region} \
--group-id ${sgid} \
--ip-permissions IpProtocol=${protocol},FromPort=${port},ToPort=${port},IpRanges='[{CidrIp=${ip},Description=\"${descricao}\"}]' " > isertrule.sh

#Para debugar retire o comentario da linha abaixo.
cat isertrule.sh

chmod +x isertrule.sh
./isertrule.sh


rm sgid isertrule.sh
