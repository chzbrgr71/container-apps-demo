param storageAccountName string
param location string
param fileShareName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource myStorage 'Microsoft.Storage/storageAccounts/fileServices/shares@2019-06-01' = {
  name: '${storageAccount.name}/default/${fileShareName}'
}

output storageAccountName string = storageAccountName
output storageAccountId string = storageAccount.id
