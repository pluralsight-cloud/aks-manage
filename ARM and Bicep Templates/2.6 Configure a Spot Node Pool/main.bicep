var location  = resourceGroup().location
var osDiskSizeGB  = 128
var agentVMSize = 'Standard_D2s_v3'
var osTypeLinux = 'Linux'

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
    agentPoolProfiles: [
      {
        name: 'syspool'
        osDiskSizeGB: osDiskSizeGB
        count: 1
        vmSize: agentVMSize
        osType: osTypeLinux
        type: 'VirtualMachineScaleSets'
        mode: 'System'
      }
    ]
  }
}
