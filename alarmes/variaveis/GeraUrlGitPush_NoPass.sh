#!/bin/bash
declare -a codecommit

readarray codecommit < codecommit

for ((i=0; i < ${#codecommit[@]}; i++)); do

echo -e "#!/bin/bash\n" >> UrlGitPush.sh
echo cd ${codecommit[i]} >> UrlGitPush.sh
echo git push https://git-codecommit.$region.amazonaws.com/v1/repos/${codecommit[i]} >> UrlGitPush.sh
echo cd .. >> UrlGitPush.sh

done

