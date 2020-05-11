#!/bin/bash 

set -e 

echo "starting vault..."


./dev-config.sh > /tmp/dev.json

[ -n "$VAULT_UNSEAL_KEY" ] && ./unsealer.sh &

vault server -config=/tmp/dev.json

