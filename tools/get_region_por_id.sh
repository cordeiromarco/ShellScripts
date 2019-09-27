#!/bin/sh
echo $1 | ./search_instance.sh | grep REGION | awk '{print $2}' | sed 's/.//10' > region
region=$(<region)
rm region
