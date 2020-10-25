# https://docs.microsoft.com/en-us/azure/app-service/scripts/cli-configure-ssl-certificate
# https://docs.microsoft.com/en-us/azure/app-service/configure-ssl-bindings#automate-with-scripts


#!/bin/bash

fqdn=<replace-with-www.{yourdomain}>
pfxPath=<replace-with-path-to-your-.PFX-file>
pfxPassword=<replace-with-your=.PFX-password>
resourceGroup=myResourceGroup
webappname=mywebapp$RANDOM

# Create a resource group.
az group create --location westeurope --name $resourceGroup

# Create an App Service plan in Basic tier (minimum required by custom domains).
az appservice plan create --name $webappname --resource-group $resourceGroup --sku B1
#az appservice plan create --name myAuthAppServicePlan --resource-group myAuthResourceGroup --sku FREE --is-linux


# Create a web app.
az webapp create --name $webappname --resource-group $resourceGroup \
--plan $webappname

echo "Configure a CNAME record that maps $fqdn to $webappname.azurewebsites.net"
read -p "Press [Enter] key when ready ..."

# Before continuing, go to your DNS configuration UI for your custom domain and follow the
# instructions at https://aka.ms/appservicecustomdns to configure a CNAME record for the
# hostname "www" and point it your web app's default domain name.

# Map your prepared custom domain name to the web app.
az webapp config hostname add --webapp-name $webappname --resource-group $resourceGroup \
--hostname $fqdn

# Upload the SSL certificate and get the thumbprint.
thumbprint=$(az webapp config ssl upload --certificate-file $pfxPath \
--certificate-password $pfxPassword --name $webappname --resource-group $resourceGroup \
--query thumbprint --output tsv)

# Binds the uploaded SSL certificate to the web app.
az webapp config ssl bind --certificate-thumbprint $thumbprint --ssl-type SNI \
--name $webappname --resource-group $resourceGroup

echo "You can now browse to https://$fqdn"



#################3
# http://www.redbaronofazure.com/?cat=231
# create the AppService if it doesn't exists
VAR0=$(az webapp show -n "$AZAPPNAME" -g "$AZRGNAME" --query "defaultHostName" -o tsv )
if [ -z "$VAR0" ]; then
    echo "create AppService=$AZAPPNAME"
    az webapp create -g "$AZRGNAME" -p "$AZAPPPLAN" -n "$AZAPPNAME" -r "python|3.7"
    az webapp config set -g "$AZRGNAME" -n "$AZAPPNAME" --min-tls-version 1.2 --linux-fx-version "PYTHON|3.7"
    az webapp log config -g "$AZRGNAME" -n "$AZAPPNAME" --web-server-logging filesystem --docker-container-logging filesystem
fi

az webapp config appsettings set -g "$AZRGNAME" -n "$AZAPPNAME" --settings "SCM_DO_BUILD_DURING_DEPLOYMENT=true" "AZTENANTID=$AZTENANTID" "AZAPPID=$AZAPPID"
az webapp deployment source config-zip -g "$AZRGNAME" -n "$AZAPPNAME" --src ./deploy.zip






az webapp create -g "$AZRGNAME" -p "$AZAPPPLAN" -n "$AZAPPNAME" -r "python|3.7"

az webapp create -g test-appservice -p test-appservice-tls12-appsvcplan -n fxtestwebapp2
az webapp config set -g test-appservice -n fxtestwebapp2 --min-tls-version 1.2 --linux-fx-version "PYTHON|3.7"
az webapp update -g test-appservice -n fxtestwebapp2 --help



az webapp create -g test-appservice -p test-appservice-tls12-appsvcplan -n fxtestwebapp2 # Default is 1.2
az webapp config set -g test-appservice -n fxtestwebapp2 --min-tls-version 1.2
az webapp update -g test-appservice -n fxtestwebapp2 --https-only





# premium
az webapp auth update -g test-appservice -n test-appservice-tls12-appsvc --action LoginWithAzureActiveDirectory
az webapp auth update --action LoginWithAzureActiveDirectory -n

--enabled true



################### BLUEPRINT
export AZRGNAME="test-appservice3manual"
export AZAPPPLAN="$AZRGNAME-svcplan"
export AZAPPNAME="$AZRGNAME-webapp"

az appservice plan create --name "$AZAPPPLAN" --resource-group "$AZRGNAME" --sku FREE --is-linux
az webapp create -g "$AZRGNAME" -p "$AZAPPPLAN" -n "$AZAPPNAME" -r "python|3.7"
az webapp config set -g "$AZRGNAME" -n "$AZAPPNAME" --min-tls-version 1.2
az webapp update -g "$AZRGNAME" -n "$AZAPPNAME" --https-only
az webapp auth update -g "$AZRGNAME" -n "$AZAPPNAME" --enabled true
az webapp auth update -g "$AZRGNAME" -n "$AZAPPNAME" --action LoginWithAzureActiveDirectory
az webapp config access-restriction set -g "$AZRGNAME" -n "$AZAPPNAME" --use-same-restrictions-for-scm-site
# VNET ?
# CONFIG SETTING FOR VNET

# Find policy alias for web tls
az provider show --namespace Microsoft.Web --expand "resourceTypes/aliases" --query "resourceTypes[].aliases[].name"|convertfrom-json|sort|sls tls
Microsoft.Web/sites/config/minTlsVersion
Microsoft.Web/sites/config/scmMinTlsVersion
Microsoft.Web/sites/config/web.minTlsVersion
Microsoft.Web/sites/siteConfig.minTlsVersion
Microsoft.Web/sites/siteConfig.scmMinTlsVersion
Microsoft.Web/sites/slots/config/minTlsVersion
Microsoft.Web/sites/slots/config/scmMinTlsVersion
Microsoft.Web/sites/slots/config/web.minTlsVersion
Microsoft.Web/sites/slots/siteConfig.minTlsVersion
Microsoft.Web/sites/slots/siteConfig.scmMinTlsVersion