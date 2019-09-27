#!/bin/bash
aws codecommit list-repositories --profile $conta --region $region --output text | awk '{print $3}' > codecommit
