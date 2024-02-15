#!/bin/bash
while true; do
  echo $(aws ssm get-parameters --name authRecordEncrypted --region us-east-1 --output text --with-decryption --query Parameters[].Value) > /etc/nginx/.htpassw
  sleep 5
done