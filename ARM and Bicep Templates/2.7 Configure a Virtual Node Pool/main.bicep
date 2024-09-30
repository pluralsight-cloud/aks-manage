var location  = resourceGroup().location
var osDiskSizeGB  = 128
var agentVMSize = 'Standard_D2s_v3'
var osTypeLinux = 'Linux'

resource aksvnet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-aks'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'NodeSubnet'
        properties: {
          addressPrefix: '10.1.0.0/22'
        }
      }
      {
        name: 'ACISubnet'
        properties: {
          addressPrefix: '10.1.4.0/22'
        }
      }
    ]
  }
}

resource devcluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  location: location
  name: 'devcluster'
  tags: {
    displayname: 'Dev AKS Cluster'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: 'devcluster'
    networkProfile: {
      networkPlugin: 'azure'
    }
    agentPoolProfiles: [
      {
        name: 'syspool'
        osDiskSizeGB: osDiskSizeGB
        count: 1
        vmSize: agentVMSize
        osType: osTypeLinux
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        vnetSubnetID: aksvnet.properties.subnets[0].id
      }
    ]
  }
}
