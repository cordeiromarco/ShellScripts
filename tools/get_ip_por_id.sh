#!/bin/sh
echo $1 | ./search_instance.sh | grep 'EXTERNAL' | awk '{print $3}'  > ip
ip=$(<ip)
rm ip
