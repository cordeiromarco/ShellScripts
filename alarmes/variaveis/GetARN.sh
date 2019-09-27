#!/bin/bash
cat ~/.aws/config  | grep ${ID} | awk '{print $3}' > arn
arn=$(<arn)
