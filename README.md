# Manage Azure Kubernetes Service (AKS)

## Module 1: Secure AKS Cluster API Networking

### Securing the AKS Cluster API

- [Secure access to the API server using authorized IP address ranges in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/api-server-authorized-ip-ranges)
- [Define API server authorized IP ranges](https://learn.microsoft.com/azure/aks/api-server-authorized-ip-ranges)
- [Create a private Azure Kubernetes Service (AKS) cluster](https://learn.microsoft.com/azure/aks/private-clusters)

### Demo: Configure API Server Authorized IP Address Ranges

- [Demo Files](/ARM%20and%20Bicep%20Templates/1.2%20Configure%20API%20server%20authorized%20IP%20address%20ranges/) used in the Cloud Playground Sandbox.
- Create an AKS Cluster with Authorized IP Address Ranges using the Azure CLI:

```bash
az aks create -g <Resource Group> -n <Cluster Name> --generate-ssh-keys --api-server-authorized-ip-ranges "<CIDR Range 1>,<Optional CIDR Range 2>"
```

### Demo: Create a Private AKS Cluster

- [Demo Files](/ARM%20and%20Bicep%20Templates/1.3%20Create%20a%20private%20AKS%20cluster/) used in the Cloud Playground Sandbox.
- Create an AKS private cluster using the Azure CLI:

```bash
az aks create -g <Resource Group> -n <Cluster Name> --generate-ssh-keys --enable-private-cluster
```

### Accessing an AKS Private Cluster

- [Access an AKS private cluster](https://learn.microsoft.com/azure/architecture/guide/security/access-azure-kubernetes-service-cluster-api-server)

### Demo: Access an AKS Private Cluster

- [Demo Files](/ARM%20and%20Bicep%20Templates/1.5%20Access%20an%20AKS%20Private%20Cluster/) used in the Cloud Playground Sandbox.
- Run commands against a private cluster using the Azure CLI:

```bash
az aks command invoke -g <Resource Group> -n <Cluster Name> -c "kubectl get namespaces"
```

- Query for the cluster API server access profile and FQDN:

```bash
az aks show -g <Resource Group> -n <Cluster Name> --query "[fqdn,apiServerAccessProfile]"
```

- Install `kubectl` using the Azure CLI:

```bash
sudo az aks install-cli
```

## Module 2: Configure AKS Scaling

### Scaling AKS Nodes

- [Use the cluster autoscaler in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/cluster-autoscaler)

### Demo: Configure Horizontal Node Scaling

- [Demo Files](/ARM%20and%20Bicep%20Templates/2.2%20Configure%20Horizontal%20Node%20Scaling/) used in the Cloud Playground Sandbox.
- Manually scale using the Azure CLI:

```bash
az aks scale -g <Resource Group> -n <Cluster Name> --nodepool-name <Node Pool Name> --node-count 3
```

- Enable the cluster autoscaler using the Azure CLI:

```bash
az aks nodepool update -g <Resource Group> --cluster-name <Cluster Name> -n <Node Pool Name> \
--enable-cluster-autoscaler --min-count 1 --max-count 3
```

### Scaling Pods with AKS

- [Scaling options for applications in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/concepts-scale)
- [https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Cooldown of scaling events](https://learn.microsoft.com/azure/aks/concepts-scale#cooldown-of-scaling-events)

### Demo: Configure Horizontal Pod Scaling

- [Demo Files](/ARM%20and%20Bicep%20Templates/2.4%20Configure%20Horizontal%20Pod%20Scaling/) used in the Cloud Playground Sandbox.
- Manually scale pods:

 ```bash
kubectl scale --replicas=3 deployment/<deployment name>
```

### Configuring Spot and Virtual Nodes

- [Add an Azure Spot node pool to an Azure Kubernetes Service (AKS) cluster](https://learn.microsoft.com/azure/aks/spot-node-pool)
- [Create and configure an Azure Kubernetes Services (AKS) cluster to use virtual nodes](https://learn.microsoft.com/azure/aks/virtual-nodes)

### Demo: Configure a Spot Node Pool

- [Demo Files](/ARM%20and%20Bicep%20Templates/2.6%20Configure%20a%20Spot%20Node%20Pool/) used in the Cloud Playground Sandbox.

### Demo: Configure a Virtual Node Pool

- [Demo Files](/ARM%20and%20Bicep%20Templates/2.7%20Configure%20a%20Virtual%20Node%20Pool/) used in the Cloud Playground Sandbox.
- Enable virtual nodes for use with your AKS cluster:

```bash
az aks enable-addons \
    --resource-group <Resource Group> \
    --name <Cluster Name> \
    --addons virtual-node \
    --subnet-name <Subnet Name>
```
