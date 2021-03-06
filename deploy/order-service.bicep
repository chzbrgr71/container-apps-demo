param location string = resourceGroup().location
param environmentId string
param orderImage string
param isOrderExternalIngress bool
param env array = []
param orderMinReplicas int = 0
param secrets array = []

var containerAppName = 'order-service'

resource orderContainerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: containerAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: environmentId
    configuration: {
      secrets: secrets
      activeRevisionsMode: 'multiple'
      ingress: {
        external: isOrderExternalIngress
        targetPort: 8082
        transport: 'auto'
      }
      dapr: {
        enabled: true
        appId: containerAppName
        appProtocol: 'http'
        appPort: 8082
      } 
    }
    template: {
      containers: [
        {
          image: orderImage
          name: containerAppName
          probes: [
            {
              type: 'liveness'
              httpGet: {
                path: '/healthz'
                port: 8082
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
        minReplicas: orderMinReplicas
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

output fqdn string = orderContainerApp.properties.configuration.ingress.fqdn
