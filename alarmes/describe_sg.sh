aws ec2 describe-security-groups \
--group-ids sg-eb97d498 \
--profile viacaocometa --region us-east-1 \
--output text | grep 'IPRANGES' | awk '{print $2}' > IPs

aws ec2 describe-security-groups \
--group-ids sg-eb97d498 \
--profile viacaocometa --region us-east-1 \
--output text | grep 'IPPERMISSIONS\|IPRANGES' | sed '/IPRANGES/{/\n/d;g;}' | awk '{print $2}' | sed 's/-1/All/g'> PORT

aws ec2 describe-security-groups \
--group-ids sg-eb97d498 \
--profile viacaocometa --region us-east-1 \
--output text | grep 'IPPERMISSIONS\|IPRANGES' | sed '/IPRANGES/{/\n/d;g;}' | awk '{print $3}' > PROTOCOL

aws ec2 describe-security-groups \
--group-ids sg-eb97d498 \
--profile viacaocometa --region us-east-1 \
--output text | grep 'IPRANGES' |  awk -F "\t" '{print $3}'> DESCRIPTION

declare -a IPs
declare -a PORT
declare -a PROTOCOL
declare -a DESCRIPTION
readarray IPs < IPs
readarray PORT < PORT
readarray PROTOCOL < PROTOCOL
readarray DESCRIPTION < DESCRIPTION


for ((i=0; i < ${#IPs[@]}; i++)); do
echo ${PORT[i]}${PROTOCOL[i]}
echo ${IPs[i]}${DESCRIPTION[i]} 
done

#echo $PORT
#echo $PROTOCOL
#echo $DESCRIPTION

rm DESCRIPTION IPs PORT PROTOCOL
