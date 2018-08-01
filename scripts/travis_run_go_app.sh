#!/usr/bin/env bash

# delayed added to ensure consul has started on host - intermittent failures
sleep 5

# Put Redis Password in Vault

VAULT_TOKEN=`cat /usr/local/bootstrap/.vault-token`
VAULT_ADDR="http://${LEADER_IP}:8200"

curl \
    --location \
    --header "X-Vault-Token: ${VAULT_TOKEN}" \
    --request POST \
    --data "{ \"data\" : { \"REDIS_MASTER_PASSWORD\" : \"\" } }" \
    ${VAULT_ADDR}/v1/secret/data/development

go get ./...
go build -o webcounter main.go
./webcounter &

page_hit_counter=`lynx --dump http://localhost:8080 | awk 'FNR==3{ print $1 }'`
echo $page_hit_counter
next_page_hit_counter=`lynx --dump http://localhost:8080 | awk 'FNR==3{ print $1 }'`
echo $next_page_hit_counter
if (( next_page_hit_counter > page_hit_counter )); then
 echo "Successful Page Hit Update"
 exit 0
else
 echo "Failed Page Hit Update"
 exit 1
fi
# The End
