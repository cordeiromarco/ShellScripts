#!/bin/sh
echo $1 | ./search_instance.sh | grep KEY | awk '{print $3}' > key
key=$(<key)
rm key
