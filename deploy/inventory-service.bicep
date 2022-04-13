param location string = resourceGroup().location
param environmentId string
param inventoryImage string
param isInventoryExternalIngress bool
param env array = []
param inventoryMinReplicas int = 0

var containerAppName = 'inventory-service'

resource inventoryContainerApp 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: environmentId
    configuration: {
      ingress: {
        external: isInventoryExternalIngress
        targetPort: 8081
        transport: 'auto'
      }
    }
    template: {
      containers: [
        {
          image: inventoryImage
          name: containerAppName
          env: env
          resources: {
            cpu: '0.75'
            memory: '1.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: inventoryMinReplicas
      }
    }
  }
}

output fqdn string = inventoryContainerApp.properties.configuration.ingress.fqdn
