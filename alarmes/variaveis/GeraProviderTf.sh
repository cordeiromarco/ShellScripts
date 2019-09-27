#!/bin/bash
#profile
echo provider \"aws\" { >> provider.tf
echo '  'region = \"${region}\" >> provider.tf
echo '  'assume_role { >> provider.tf
echo '  'role_arn     = \"${arn}\"  >> provider.tf
echo '  'session_name = \"${conta}\" >> provider.tf
echo '  '} >> provider.tf
echo } >> provider.tf



sed -i 's/ "/"/g' provider.tf
sed -i 's/ :/:/g' provider.tf
sed -i 's/="/= "/g' provider.tf
sed -i 's/provider"/provider "/g' provider.tf

