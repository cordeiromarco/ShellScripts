#!/bin/sh
aws elb describe-load-balancers \
--profile $conta --region $region \
--output text \
--query 'LoadBalancerDescriptions[].LoadBalancerName[]' \
> ListNameELB &&\
sed -i 's/	/\n/g' ListNameELB
declare -a ListNameELB
readarray ListNameELB < ListNameELB

