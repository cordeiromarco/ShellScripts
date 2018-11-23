#!/bin/bash

#check top 10 process with high memory utilization
clear
echo
echo "top 10 process with high memory utilization";
echo
ps aux --sort=-%mem | awk 'NR<=10{print $0}'
echo
echo

