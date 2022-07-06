## Notes

Docs. https://docs.microsoft.com/en-us/azure/container-apps/overview

#### Local Debug

```bash

# storage
az containerapp env storage set --name env-dxpxn7jusu4ww --resource-group briar-container-app-demo-20265 \
    --storage-name mystorage \
    --azure-file-account-name sadxpxn7jusu4ww \
    --azure-file-account-key Vi2YR4n6GJklpPX/KKWhBuJd14dduAWxq04BfA3eTMzneNDbTFw0UtS/o9ysi3MJMQtpzoLOPUEU+AStCacuLQ== \
    --azure-file-share-name shareddata \
    --access-mode ReadWrite

az containerapp show -n inventory-service -g briar-container-app-demo-20265 -o yaml > app.yaml
az containerapp update --name inventory-service --resource-group briar-container-app-demo-20265 \
    --yaml app.yaml

while true; do curl https://inventory-service.blackbay-7ef570dd.eastus.azurecontainerapps.io/allinventory && echo '' ; sleep 2; done

curl https://inventory-service.blackbay-7ef570dd.eastus.azurecontainerapps.io/allinventory

while true; do curl https://store-service.blackbay-7ef570dd.eastus.azurecontainerapps.io/orderbyid?id=232323 && echo '' ; sleep 2; done

curl https://store-service.blackbay-7ef570dd.eastus.azurecontainerapps.io/orderbyid?id=232323

# inventory
dapr run --app-id inventory-service --app-port 8081 --dapr-http-port 9081 --dapr-grpc-port 7081 npm start
dapr run --app-id inventory-service --app-port 8081 --dapr-http-port 9081 npm start

curl http://0.0.0.0:8081/inventorybyid?id=9
curl http://0.0.0.0:8081/allinventory
curl http://localhost:9081/v1.0/invoke/inventory-service/method/allinventory

curl https://inventory-service.greenhill-45a5e1c2.eastus.azurecontainerapps.io/allinventory

# order
dapr run --app-id order-service --app-port 8082 --dapr-http-port 9082 npm start
dapr run --app-id order-service --components-path ./components-brian --app-port 8082 --dapr-http-port 9082 --dapr-grpc-port 7082 npm start

curl http://0.0.0.0:8082/healthz
curl http://localhost:9082/v1.0/invoke/order-service/method
curl http://0.0.0.0:8082/orderbyid?id=990310

curl http://0.0.0.0:8082/createorder -X POST -H 'Content-Type: application/json' -d '{"orderid":"990310","itemid":"3","description":"MSR Snow shoes","location":"Denver","priority":"Standard"}'

export ORDER_URL=https://order-service.greenhill-45a5e1c2.eastus.azurecontainerapps.io
curl $ORDER_URL/createorder -X POST -H 'Content-Type: application/json' -d '{"orderid":"444444","itemid":"3","description":"Crappy Snow shoes","location":"Denver","priority":"Standard"}'

# store
dapr run --app-id store-service --app-port 8083 --dapr-http-port 9083 --dapr-grpc-port 7083 npm start

curl http://0.0.0.0:8083/healthz
curl http://0.0.0.0:8083/allinventory
curl http://0.0.0.0:8083/inventorystatus 
curl http://0.0.0.0:8083/orderbyid?id=990310 
curl http://0.0.0.0:8083/inventorybyid?id=9
curl http://0.0.0.0:8083/neworder -X POST -H 'Content-Type: application/json' -d '{"orderid":"990310","itemid":"3","description":"MSR Snow shoes","location":"Denver","priority":"Standard"}'

curl https://store-service.blackbay-7ef570dd.eastus.azurecontainerapps.io/neworder -X POST -H 'Content-Type: application/json' -d '{"orderid":"232323","itemid":"3","description":"REI Brand Snow shoes","location":"Denver","priority":"Rush"}'

curl https://store-service.mangosky-f6a39d77.eastus.azurecontainerapps.io/neworder -X POST -H 'Content-Type: application/json' -d '{"orderid":"123456","itemid":"3","description":"Santa Cruz MTB","location":"Colorado Springs","priority":"Rush"}'

dapr invoke --app-id store-service --method neworder --data '{"orderid":"990310","itemid":"3","description":"MSR Snow shoes","location":"Denver","priority":"Standard"}'
```

#### Test the app

Sample order payloads:
{"orderid":"900101","itemid":"1","description":"Thule Roof Rack Base System","location":"Denver","priority":"Express"}
{"orderid":"200881","itemid":"2","description":"Thule Kayak Carrier","location":"Denver","priority":"Standard"}
{"orderid":"190310","itemid":"3","description":"MSR Snow shoes","location":"Denver","priority":"Standard"}
{"orderid":"109584","itemid":"4","description":"Smith Vantage MIPS Ski Helmet","location":"Denver","priority":"Standard"}
{"orderid":"112409","itemid":"5","description":"Kuat Bike carrier - tow hitch","location":"Denver","priority":"Express"}
{"orderid":"113982","itemid":"6","description":"Hestra Gloves Heli Insulated Mittens","location":"Denver","priority":"Standard"}
{"orderid":"201551","itemid":"7","description":"Santa Cruz Hightower 29er MTB","location":"Denver","priority":"Standard"} 
{"orderid":"202903","itemid":"8","description":"Deuter Aircontact Lite 65 + 10 Pack","location":"Denver","priority":"Standard"}
{"orderid":"110910","itemid":"9","description":"Big Agnes Copper Spur HV UL2 Tent","location":"Denver","priority":"Standard"}
{"orderid":"100101","itemid":"10","description":"Jetboil Flash Cooking System","location":"Denver","priority":"Express"} 

```bash

# store
curl -X GET https://store-service.wittyhill-cddf9e15.eastus.azurecontainerapps.io/order?id=1
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"id":"2","item":"Ski Carrier","location":"Seattle","priority":"Standard"}' \
  https://store-service.wittyhill-cddf9e15.eastus.azurecontainerapps.io/order?id=undefined

# orders
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"id":"3","item":"Bike Carrier","location":"Seattle","priority":"Standard"}' \
  https://order-service.wittyhill-cddf9e15.eastus.azurecontainerapps.io/order?id=undefined

curl --header "Content-Type: application/json" --request POST --data '{"id":"4","item":"Rack Locking System","location":"Denver","priority":"Standard"}' https://order-service.wittyhill-cddf9e15.eastus.azurecontainerapps.io/order?id=undefined

# inventory
curl -X GET https://inventory-service.wittyhill-cddf9e15.eastus.azurecontainerapps.io/
curl -X GET https://inventory-service.wittyhill-cddf9e15.eastus.azurecontainerapps.io/inventory

docker run --rm -p 8050:8050 --name inv chzbrgr71/inventory-service:v1.5

# looptid
while true; do curl --header "Content-Type: application/json" --request POST --data '{"id":"4","item":"Rack Locking System","location":"Denver","priority":"Standard"}' https://order-service.wittyhill-cddf9e15.eastus.azurecontainerapps.io/order?id=undefined && echo '' ; sleep 3; done

```

#### Revisions

ghcr.io/azure/container-apps-demo/inventory-service:aeb9f27
ghcr.io/azure/container-apps-demo/inventory-service:ece45f9

```bash
az containerapp update \
  --name inventory-service \
  --resource-group $RG \
  --image ghcr.io/azure/container-apps-demo/inventory-service:ece45f9

az containerapp update \
  --name inventory-service \
  --resource-group $RG \
  --image ghcr.io/azure/container-apps-demo/inventory-service:aeb9f27  

while true; do curl https://inventory-service.livelyflower-ad51a38b.eastus.azurecontainerapps.io && echo '' ; sleep 1; done

az containerapp revision list -g vscode-container-app-demo-25161 -n store-service

az containerapp revision show -g vscode-container-app-demo-25161 --app store-service -n store-service--ftpc5po -o json

az containerapp revision show -g vscode-container-app-demo-25161 --app store-service -n store-service--ftpc5po -o json | jq -r '.replicas'

az containerapp revision list -g reddog-briar-ca -n virtual-customers
```

#### Logs

```bash

export RG=''
export LOG_ANALYTICS_WORKSPACE=''

export LOG_ANALYTICS_WORKSPACE_CLIENT_ID=`az monitor log-analytics workspace show --query customerId -g $RG -n $LOG_ANALYTICS_WORKSPACE --out tsv`

az monitor log-analytics query \
  --workspace $LOG_ANALYTICS_WORKSPACE_CLIENT_ID \
  --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == 'store-service' | project ContainerAppName_s, Log_s, TimeGenerated " \
  --out table

az monitor log-analytics query \
  --workspace $LOG_ANALYTICS_WORKSPACE_CLIENT_ID \
  --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == 'order-service' | project ContainerAppName_s, Log_s, TimeGenerated " \
  --out table

az monitor log-analytics query \
  --workspace $LOG_ANALYTICS_WORKSPACE_CLIENT_ID \
  --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == 'inventory-service' | project ContainerAppName_s, Log_s, TimeGenerated " \
  --out table
```

#### Custom VNET

```bash
RESOURCE_GROUP=''
LOCATION='canadacentral'
CONTAINERAPPS_ENVIRONMENT=''
VNET_NAME=''

az group create --name $RESOURCE_GROUP --location $LOCATION

az network vnet create --resource-group $RESOURCE_GROUP --name $VNET_NAME --location $LOCATION  --address-prefix 10.0.0.0/16

az network vnet subnet create --resource-group $RESOURCE_GROUP --vnet-name $VNET_NAME --name infrastructure --address-prefixes 10.0.0.0/23  

VNET_RESOURCE_ID=`az network vnet show --resource-group ${RESOURCE_GROUP} --name ${VNET_NAME} --query "id" -o tsv | tr -d '[:space:]'`
INFRASTRUCTURE_SUBNET=`az network vnet subnet show --resource-group ${RESOURCE_GROUP} --vnet-name $VNET_NAME --name infrastructure --query "id" -o tsv | tr -d '[:space:]'`

az containerapp env create \
  --name $CONTAINERAPPS_ENVIRONMENT \
  --resource-group $RESOURCE_GROUP \
  --location "$LOCATION" \
  --infrastructure-subnet-resource-id $INFRASTRUCTURE_SUBNET \
  --internal-only --debug

az containerapp env show --name ${CONTAINERAPPS_ENVIRONMENT} --resource-group ${RESOURCE_GROUP} -o json

ENVIRONMENT_DEFAULT_DOMAIN=`az containerapp env show --name ${CONTAINERAPPS_ENVIRONMENT} --resource-group ${RESOURCE_GROUP} --query properties.defaultDomain --out json | tr -d '"'`
ENVIRONMENT_STATIC_IP=`az containerapp env show --name ${CONTAINERAPPS_ENVIRONMENT} --resource-group ${RESOURCE_GROUP} --query properties.staticIp --out json | tr -d '"'`
VNET_ID=`az network vnet show --resource-group ${RESOURCE_GROUP} --name ${VNET_NAME} --query id --out json | tr -d '"'`

az containerapp create \
  --name test-app-1 \
  --resource-group $RESOURCE_GROUP \
  --environment $CONTAINERAPPS_ENVIRONMENT \
  --image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest \
  --target-port 80 \
  --ingress 'external' \
  --query properties.configuration.ingress.fqdn

az containerapp exec -g $RESOURCE_GROUP -n test-app-1

```