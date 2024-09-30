var location  = resourceGroup().location
var osDiskSizeGB  = 128
var agentCount = 1
var agentVMSize = 'Standard_D2s_v3'
var osTypeLinux = 'Linux'

resource prodcluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  location: location
  name: 'prodcluster'
  tags: {
    displayname: 'Production AKS Cluster'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    apiServerAccessProfile: {
      enablePrivateCluster: true
      subnetId: // Resource ID for existing subnet
    }
    agentPoolProfiles: [
      {
        name: 'syspool'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVMSize
        osType: osTypeLinux
        type: 'VirtualMachineScaleSets'
        mode: 'System'
      }
    ]
  }
}
