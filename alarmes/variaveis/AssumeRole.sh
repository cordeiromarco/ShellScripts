######Aqui pegamos as informações de conta e região
read -p "Digite o nome conta que deseja fazer a consulta[default]: " conta

if [ -z "${conta}" ]; then
    FOO=${conta:=default}
else
    FOO=${conta}
fi

read -p "Digite a Região que deseja fazer a consulta[us-east-1]: " region

if [ -z "${region}" ]; then
    FOO=${region:=us-east-1}
else
    FOO=${region}
fi

echo
#get id conta
echo awk  \'\$1 == \"$conta\" {print \$NF}\' /home/fedora/scripts/listas/contas.txt \> tmpid > tmpawk
sed -i 's/ "/"/g' tmpawk

chmod +x tmpawk
./tmpawk
idconta=$(<tmpid)
#Padroniza o nome da conta em maiusculo para usar no nome do Alarme
contaupper=${conta^^}

if [ $contaupper == DEFAULT ]; then
	contaupper=IPSENSE
else
	contaupper=${conta^^}
fi


rm tmpawk tmpid
