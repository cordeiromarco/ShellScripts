#!/bin/bash

echo -e "\nPara ver a lista de Regiões execute o script com parametro '-r' para ver a lista de Clientes execute com '-c' e '-a' para listar amabos \n "


while getopts ':cra' option; do
  case "$option" in
    c) cat /home/fedora/scripts/listas/ListaClientes.txt
       exit
       ;;
    r) cat /home/fedora/scripts/listas/ListaRegiao.txt
       exit
       ;;
    a) cat /home/fedora/scripts/listas/ListaRegiao.txt
       echo -e "\n"
       cat /home/fedora/scripts/listas/ListaClientes.txt
       exit
       ;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done
shift $((OPTIND - 1))


