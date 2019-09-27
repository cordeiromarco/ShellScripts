#!/bin/bash
declare -a codecommit

readarray codecommit < codecommit

for ((i=0; i < ${#codecommit[@]}; i++)); do 

echo resource \"aws_codecommit_repository\" \"${codecommit[i]}\" { >> CodeCommit.tf
echo ' 'repository_name = \"${codecommit[i]}\" >> CodeCommit.tf
echo ' 'description     = \"Repository: ${codecommit[i]}\" >> CodeCommit.tf
echo } >> CodeCommit.tf

done


sed -i 's/ "/"/g' CodeCommit.tf
sed -i 's/""/" "/g' CodeCommit.tf
sed -i 's/resource"/resource "/g' CodeCommit.tf
sed -i 's/="/= "/g' CodeCommit.tf


