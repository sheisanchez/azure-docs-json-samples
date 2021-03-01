param storagePrefix string {
  minLength: 3
  maxLength: 11
}
param storageSKU string {
  allowed: [
    'Standard_LRS'
    'Standard_GRS'
    'Standard_RAGRS'
    'Standard_ZRS'
    'Premium_LRS'
    'Premium_ZRS'
    'Standard_GZRS'
    'Standard_RAGZRS'
  ]
  default: 'Standard_LRS'
}
param location string = resourceGroup().location
param appServicePlanName string = 'exampleplan'
param webAppName string {
  minLength: 2
  metadata: {
    description: 'Base name of the resource such as web app name and app service plan '
  }
}
param linuxFxVersion string {
  metadata: {
    description: 'The Runtime stack of current web app'
  }
  default: 'php|7.0'
}

var uniqueStorageName = concat(storagePrefix, uniqueString(resourceGroup().id))
var webAppPortalName = concat(webAppName, uniqueString(resourceGroup().id))

resource stg 'Microsoft.Storage/storageAccounts@2019-04-01' = {
  name: uniqueStorageName
  location: location
  sku: {
    name: storageSKU
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

resource appPlan 'Microsoft.Web/serverfarms@2016-09-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    family: 'B'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    perSiteScaling: false
    reserved: true
    targetWorkerCount: 0
    targetWorkerSizeId: 0
  }
}

resource site 'Microsoft.Web/sites@2020-06-01' = {
  name: webAppPortalName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appPlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
    }
  }
}

output storageEndpoint object = stg.properties.primaryEndpoints