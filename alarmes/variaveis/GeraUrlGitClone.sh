#!/bin/bash
declare -a codecommit

readarray codecommit < codecommit

for ((i=0; i < ${#codecommit[@]}; i++)); do

echo -e "#!/bin/bash\n" >> UrlGitClone.sh
echo git clone https://$user:$pass@git-codecommit.$region.amazonaws.com/v1/repos/${codecommit[i]} >> UrlGitClone.sh

done

