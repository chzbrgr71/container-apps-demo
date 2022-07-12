param environmentName string
param logAnalyticsWorkspaceName string = 'logs-${environmentName}'
param appInsightsName string = 'appins-${environmentName}'
param storageAccountName string = 'sa${uniqueString(resourceGroup().id)}'
param storageFileShare string = 'shareddata'
param location string = resourceGroup().location
param cosmosAccountName string
param cosmosDbEndpoint string

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2021-06-15' existing = {
  name: cosmosAccountName
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: { 
    Application_Type: 'web'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource myStorage 'Microsoft.Storage/storageAccounts/fileServices/shares@2019-06-01' = {
  name: '${storageAccount.name}/default/${storageFileShare}'
}

resource environment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: environmentName
  location: location
  properties: {
    daprAIInstrumentationKey: appInsights.properties.InstrumentationKey
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
  resource daprComponent 'daprComponents@2022-03-01' = {
    name: 'cosmos-statestore'
    properties: {
      componentType: 'state.azure.cosmosdb'
      version: 'v1'
      ignoreErrors: false
      initTimeout: '5s'
      secrets: [
        {
          name: 'masterkey'
          value: listkeys(cosmosAccount.id, cosmosAccount.apiVersion).primaryMasterKey
        }
      ]      
      metadata: [
        {
          name: 'url'
          value: cosmosDbEndpoint
        }
        {
          name: 'database'
          value: 'ordersDb'
        }
        {
          name: 'collection'
          value: 'orders'
        }
        {
          name: 'masterkey'
          secretRef: 'masterkey'
        }
      ]
      scopes: [
        'order-service'
      ]      
    }
  }  
}

resource environment_name_myazurefiles 'Microsoft.App/managedEnvironments/storages@2022-03-01' = {
  parent: environment
  name: 'myazurefiles'
  properties: {
    azureFile: {
      accountName: storageAccountName
      accountKey: listkeys(storageAccount.id, storageAccount.apiVersion).keys[0].value
      shareName: storageFileShare
      accessMode: 'ReadWrite'
    }
  }
}

output location string = location
output environmentId string = environment.id
output defaultDomain string = environment.properties.defaultDomain
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output logAnalyticsName string = logAnalyticsWorkspaceName
output storageAccountName string = storageAccountName
