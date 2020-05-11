#!/bin/bash

readonly PORT=${PORT:?}

if [[ -z ${VAULT_UNSEAL_KEY+x} ]]; then
    echo "unseal key not provided -- vault needs to be manually unsealed"
    exit 0
fi

generate_post_data() {
cat <<EOF
    {"key": "${VAULT_UNSEAL_KEY}"}
EOF
}


echo "trying to unseal vault..."
FIRST=1

STATUS_URL="http://127.0.0.1:8080/v1/sys/health"

while true
do

  STATUS=$(curl -s -o /dev/null -w '%{http_code}' $STATUS_URL)
  echo "status = ${STATUS}"

  case $STATUS in
  200) echo "initialized, unsealed and active" ; break ;;
  429) echo "unsealed and standby" ; break ;;
  427) echo "active in disaster recovery mode" ; break ;;
  473) echo "performance standby" ; break ;;
  501) echo "not initialized" ; break ;;

  503)
    echo "listening and sealed; sending unseal key"
	curl -s -X PUT -d "$(generate_post_data)" http://127.0.0.1:${PORT:?}/v1/sys/unseal
  ;;

  *)
    if [ ${FIRST} -eq 1 ]; then
        echo "waiting for listener.."
        FIRST=0
    fi

    echo -n "."
    sleep 1
  ;;

  esac

done
