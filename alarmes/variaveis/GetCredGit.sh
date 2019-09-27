#!/bin/bash
#!/bin/bash

cat /home/fedora/scripts/listas/.credenciaisgit | grep $ID | awk '{print $3}' | sed 's/!/%21/g' | sed 's/#/%23/g' | sed 's/\$/%24/g' | sed 's/&/%26/g' | sed "s/'/%27/g" | sed 's/(/%28/g' | sed 's/)/%29/g' | sed 's/*/%2A/g' | sed 's/+/%2B/g' | sed 's/,/%2C/g' | sed 's/\//%2F/g' | sed 's/:/%3A/g' | sed 's/;/%3B/g' | sed 's/=/%3D/g' | sed 's/?/%3F/g' | sed 's/@/%40/g' | sed 's/\[/%5B/g' | sed 's/]/%5D/g' > pass
cat /home/fedora/scripts/listas/.credenciaisgit | grep $ID | awk '{print $2}' | sed 's/@/%40/g' > user

pass=$(<pass)
user=$(<user)
