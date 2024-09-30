var location  = resourceGroup().location
var osDiskSizeGB  = 128
var agentCount = 1
var agentVMSize = 'Standard_D2s_v3'
var osTypeLinux = 'Linux'

resource publicIPPrefix 'Microsoft.Network/publicIPPrefixes@2019-11-01' = {
  name: 'ippre-nodepool-publicip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    prefixLength: 31
  }
}

resource devcluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  location: location
  name: 'devcluster'
  tags: {
    displayname: 'AKS Cluster'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: 'devcluster'
    agentPoolProfiles: [
      {
        name: 'loadbalancer'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVMSize
        osType: osTypeLinux
        type: 'VirtualMachineScaleSets'
        mode: 'System'
      }
      {
        name: 'publicip'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVMSize
        osType: osTypeLinux
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        enableNodePublicIP: true
        nodePublicIPPrefixID: publicIPPrefix.id
      }
    ]
  }
}
