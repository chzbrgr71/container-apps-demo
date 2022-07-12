param location string = 'canadacentral'
param dapr_ai_instrumentation_key string = ''
param environment_name string = 'myenvironment'
param log_analytics_customer_id string

@secure()
param log_analytics_shared_key string
param storage_account_name string

@secure()
param storage_account_key string
param storage_share_name string

resource environment_name_resource 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: environment_name
  location: location
  properties: {
    daprAIInstrumentationKey: dapr_ai_instrumentation_key
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: log_analytics_customer_id
        sharedKey: log_analytics_shared_key
      }
    }
  }
}

resource environment_name_myazurefiles 'Microsoft.App/managedEnvironments/storages@2022-03-01' = {
  parent: environment_name_resource
  name: 'myazurefiles'
  properties: {
    azureFile: {
      accountName: storage_account_name
      accountKey: storage_account_key
      shareName: storage_share_name
      accessMode: 'ReadWrite'
    }
  }
}