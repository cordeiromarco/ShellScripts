#!/bin/sh 
echo $1 | ./search_instance.sh | grep CONTA | awk '{print $2}' > conta
conta=$(<conta)
rm conta
