# Vault

Quick app to run a [Hashicorp Vault](https://www.vaultproject.io) server in a heroku dyno 

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)


## Setup 
```bash 
brew install vault vault-cli jq

export VAULT_APP=<APP NAME YOU PICKED>
export VAULT_ADDR="https://${VAULT_APP}.herokuapp.com"

vault operator init      #### stash the output of this command in a safe place!
vault operator unseal    # do this step 3x with different keys
vault status

export VAULT_TOKEN=<ROOT TOKEN FROM INIT>
vault login <ROOT TOKEN FROM INIT>      # not needed; overridden by VAULT_TOKEN
vault secrets enable kv
vault secrets list
vault kv put kv/secret/hello value=world
vault kv put kv/secret/hello value=-       # read secret from stdin
vault kv get kv/secret/hello
vault kv get -field=value kv/secret/hello
vault kv get -format=json kv/secret/hello | jq -r .data.data.value
vault kv delete kv/secret/hello

vault operator seal     # don't do this; only in case of breach/emergency


```

## AUTO-UNSEAL

For my purposes, the auto-unseal features of vault (using Cloud services, or a second vault via transit)
are all way too complicated. For this reason I've activated the upstream script that invokes the unseal API
with the VAULT_UNSEAL_KEY variable if it's set. To modify the vault configuration so it has only a single
unseal key, execute the below instructions:

```
vault operator rekey -init -key-shares=1 -key-threshold=1   # start rekeying to single key
vault operator rekey -nonce                                 # enter a key for rekeying x3
```

#### Useful Links
- [docs](https://www.vaultproject.io/docs/index.html)
- [api docs](https://www.vaultproject.io/api/index.html)
- [use cases](https://sreeninet.wordpress.com/2016/10/01/vault-use-cases/)
