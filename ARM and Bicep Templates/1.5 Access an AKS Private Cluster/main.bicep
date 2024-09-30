var location  = resourceGroup().location
var osDiskSizeGB  = 128
var agentCount = 1
var agentVMSize = 'Standard_D2s_v3'
var osTypeLinux = 'Linux'
var vmAdministratorLogin = 'aksadmin'
var vmAdministratorLoginPassword  = 'SuperSecretPassword1234'

resource vnethub 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-hub'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'AzureFirewallManagementSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'aks-jump-subnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.254.0/24'
        }
      }
    ]
  }
}

resource vnetakspoke 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-spoke-aks'
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
    ]
  }
}

// Peers

resource hubvnet_peertoaksspoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  parent: vnethub
  name: 'peertoaksspoke'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnetakspoke.id
    }
  }
}

resource aksspoke_peertohub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  parent: vnetakspoke
  name: 'peertohub'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnethub.id
    }
  }
}

resource prodcluster 'Microsoft.ContainerService/managedClusters@2024-07-01' = {
  location: location
  name: 'prodcluster'
  tags: {
    displayname: 'Prod AKS Cluster'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: 'prodcluster'
    apiServerAccessProfile: {
      enablePrivateCluster: true
      // privateDNSZone: aksdnszone.id
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
        vnetSubnetID: vnetakspoke.properties.subnets[0].id
      }
    ]
  }
}

resource BastionPIP 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: 'pip-bastion'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2023-11-01' = {
  name: 'bastion'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    scaleUnits: 2
    enableTunneling: false
    enableIpConnect: false
    disableCopyPaste: false
    enableShareableLink: false
    enableKerberos: false
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: BastionPIP.id
          }
          subnet: {
            id: vnethub.properties.subnets[3].id
          }
        }
      }
    ]
  }
}

resource aksjumpboxnic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: 'vml-aks-jumpbox-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'jumpbox1nic1ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.0.2.5'
          subnet: {
            id: vnethub.properties.subnets[2].id
          }
        }
      }
    ]
  }
}

resource aksjumpbox 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: 'vml-aks-jumpbox'
  location: location
  dependsOn: [
    bastion
    prodcluster
  ]
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    osProfile: {
      computerName: 'aks-jumpbox'
      adminUsername: vmAdministratorLogin
      adminPassword: vmAdministratorLoginPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        name: 'vml-aks-jumpbox-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: aksjumpboxnic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}

resource aksjumpbox_cse 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  parent: aksjumpbox
  name: 'vml-aks-jumpbox-cse'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    protectedSettings: {
      commandToExecute: 'curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash'
    }
  }
}
