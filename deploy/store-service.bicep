param location string = resourceGroup().location
param environmentId string
param storeImage string
param isStoreExternalIngress bool
param env array = []
param storeMinReplicas int = 0

var containerAppName = 'store-service'

resource storeContainerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: environmentId
    configuration: {
      activeRevisionsMode: 'multiple'
      ingress: {
        external: isStoreExternalIngress
        targetPort: 8083
        transport: 'auto'
      }
      dapr: {
        enabled: true
        appId: containerAppName
        appProtocol: 'http'
        appPort: 8083
      }      
    }
    template: {
      containers: [
        {
          image: storeImage
          name: containerAppName
          env: env
          probes: [
            {
              type: 'liveness'
              httpGet: { 
                path: '/healthz'
                port: 8083
              }
            }
          ]          
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
        minReplicas: storeMinReplicas
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

output fqdn string = storeContainerApp.properties.configuration.ingress.fqdn
