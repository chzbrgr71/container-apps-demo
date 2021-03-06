param location string = resourceGroup().location
param environmentId string
param inventoryImage string
param isInventoryExternalIngress bool
param env array = []
param inventoryMinReplicas int = 0

var containerAppName = 'inventory-service'

resource inventoryContainerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: environmentId
    configuration: {
      activeRevisionsMode: 'multiple'
      ingress: {
        external: isInventoryExternalIngress
        targetPort: 8081
        transport: 'auto'
      }
      dapr: {
        enabled: true
        appId: containerAppName
        appProtocol: 'http'
        appPort: 8081
      }       
    } 
    template: {
      containers: [
        {
          image: inventoryImage
          name: containerAppName
          probes: [
            {
              type: 'liveness'
              httpGet: {
                path: '/healthz'
                port: 8081
              }
              failureThreshold: 5
              periodSeconds: 15
            }
          ]          
          env: env
          resources: {
            cpu: '0.75'
            memory: '1.5Gi'
          }
          volumeMounts: [
            {
              volumeName: 'azure-files-volume'
              mountPath: '/shared-files'
            }
          ]
        }
      ]
      scale: {
        minReplicas: inventoryMinReplicas
      }
      volumes: [
        {
          name: 'azure-files-volume'
          storageType: 'AzureFile'
          storageName: 'myazurefiles'
        }
      ]
    }
  }
}

output fqdn string = inventoryContainerApp.properties.configuration.ingress.fqdn
