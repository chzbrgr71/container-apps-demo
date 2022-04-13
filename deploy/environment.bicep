param environmentName string
param logAnalyticsWorkspaceName string = 'logs-${environmentName}'
param appInsightsName string = 'appins-${environmentName}'
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

resource environment 'Microsoft.App/managedEnvironments@2022-01-01-preview' = {
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
  resource daprComponent 'daprComponents@2022-01-01-preview' = {
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

output location string = location
output environmentId string = environment.id
output defaultDomain string = environment.properties.defaultDomain
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output logAnalyticsName string = logAnalyticsWorkspaceName
