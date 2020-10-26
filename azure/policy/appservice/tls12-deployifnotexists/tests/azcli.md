```
################### BLUEPRINT
export AZRGNAME="test-appservice3manual"
export AZAPPPLAN="test-appservice3manual-svcplan"
export AZAPPNAME="test-webapp6"

# az appservice plan create --name "$AZAPPPLAN" --resource-group "$AZRGNAME" --sku FREE --is-linux
az webapp create -g "$AZRGNAME" -p "$AZAPPPLAN" -n "$AZAPPNAME" -r "python|3.7"
az webapp config set -g "$AZRGNAME" -n "$AZAPPNAME" --min-tls-version 1.1
```