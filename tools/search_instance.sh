echo
read -p "Insira o ID, IP ou nome da Instância que deseja procurar: " var
echo
cat inventario/EC2/ListaEC2_*.csv | grep -i "$var" | awk -F $'\t' '{print "CONTA: "$2"\n" "REGION: "$5"\n" "INSTANCE ID: "$14"\n" "TYPE: "$15"\n" "KEY PAIR: "$16"\n" "NAME: "$19"\n" "INTERNAL IP: "$22"\n" "EXTERNAL IP: "$24; for(i=35;i<=NF;++i)print "VOLUME ID: " $i ;print "\n"}' > output
cat output
count="$(cat output | grep "INSTANCE ID" | wc -l)"
echo "Foram encontrada(s) ${count} instancia(s)"
echo

rm output
