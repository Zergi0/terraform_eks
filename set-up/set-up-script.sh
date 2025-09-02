#!/bin/bash

mkdir -p ./secrets

ssh-keygen -t rsa -b 4096 -f ./secrets/testkey -N "" -q

USER_IP=$(curl -s https://checkip.amazonaws.com)

cat > terraform.tfvars <<EOF
bastion_host_public_key = "secrets/testkey.pub"
environment             = "dev"
project_name            = "zergi-eks-project"
keyname                 = "testkey"
db_port                 = "3306"
db_name                 = "testdb123"
db_engine               = "mysql"
db_engine_version       = "8.0"
db_username             = "adminadmin"
db_pw                   = "passpass123123"
db_parameter_group      = "default.mysql8.0"
bastion_host_ingress_ip = "${USER_IP}/32"
EOF

echo "✅ SSH keys created in ./secrets/"
echo "✅ terraform.tfvars created with user IP: ${USER_IP}/32"