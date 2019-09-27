#!/bin/bash
echo cat /home/fedora/scripts/listas/contas.txt \| grep -E \'\(\^\|\\s\)${conta}\(\$\|\\s\)\' \| awk \'{print $\2}\' \> ID >> ID.sh
chmod +x ID.sh
./ID.sh
ID=$(<ID)

