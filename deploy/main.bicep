param location string = resourceGroup().location
param environmentName string = 'env-${uniqueString(resourceGroup().id)}'

// inventory service
param inventoryMinReplicas int = 1
param inventoryImage string = 'ghcr.io/azure/container-apps-demo/inventory-service:latest'
param isInventoryExternalIngress bool = true

// order service
param orderMinReplicas int = 1
param orderImage string = 'ghcr.io/azure/container-apps-demo/order-service:latest'
param isOrderExternalIngress bool = true

// store service
param storeMinReplicas int = 1
param storeImage string = 'ghcr.io/azure/container-apps-demo/store-service:latest'
param isStoreExternalIngress bool = true

// cosmosdb
module cosmosdb 'cosmosdb.bicep' = {
  name: 'cosmosdb'
  params: {
    location: location
    primaryRegion: location
  }
}

// container app environment
module environment 'environment.bicep' = {
  name: 'container-app-environment'
  params: {
    environmentName: environmentName
    location: location
    cosmosAccountName: cosmosdb.outputs.cosmosAccountName
    cosmosDbEndpoint: cosmosdb.outputs.documentEndpoint
  }
}

// container app: store-service
module storeService 'store-service.bicep' = {
  name: 'store-service'
  params: {
    location: location
    environmentId: environment.outputs.environmentId
    storeImage: storeImage
    isStoreExternalIngress: isStoreExternalIngress
    storeMinReplicas: storeMinReplicas
    env: [
      {
        name: 'ORDER_SERVICE_NAME'
        value: 'order-service'
      }
      {
        name: 'INVENTORY_SERVICE_NAME'
        value: 'inventory-service'
      }
    ]
  }
}

// container app: order-service
module orderService 'order-service.bicep' = {
  name: 'order-service'
  params: {
    location: location
    environmentId: environment.outputs.environmentId
    orderImage: orderImage
    isOrderExternalIngress: isOrderExternalIngress
    orderMinReplicas: orderMinReplicas
    secrets: [
      {
        name: 'masterkey'
        value: cosmosdb.outputs.primaryMasterKey
      }
    ]    
  }
}

// container app: inventory-service
module inventoryService 'inventory-service.bicep' = {
  name: 'inventory-service'
  params: {
    location: location
    environmentId: environment.outputs.environmentId
    inventoryImage: inventoryImage
    isInventoryExternalIngress: isInventoryExternalIngress
    inventoryMinReplicas: inventoryMinReplicas
  }
}

output cosmosDbEndpoint string = cosmosdb.outputs.documentEndpoint
output storeFqdn string = storeService.outputs.fqdn
output orderFqdn string = orderService.outputs.fqdn
output inventoryFqdn string = inventoryService.outputs.fqdn
output environmentId string = environment.outputs.environmentId
output defaultDomain string = environment.outputs.defaultDomain
output appInsightsInstrumentationKey string = environment.outputs.appInsightsInstrumentationKey
output logAnalyticsName string = environment.outputs.logAnalyticsName
