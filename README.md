# Yagan kubernetes

## Requirements

| Name | Version |
|------|---------|
| terraform | `>= 1.3.7` |

## Providers

| Name | Version |
|------|---------|
| rke | `1.3.4` |
| helm | `2.8.0` |
| kubernetes | `2.16.1` |

## Usage

```hcl
module "cluster" {
  source = "git@github.com:bennu/terraform-kubernetes-yagan.git"

  private_key           = file("/path/to/privatekey.pem")
  node_user             = "root"
  nodes = {
    node-name-1 = [{
      ip     = "1.1.1.1"
      type   = ["controlplane", "etcd"]
      labels = {}
      taints = []
    }],
    node-name-2 = [{
      ip     = "2.2.2.2"
      type   = ["worker"]
      labels = {}
      taints = []
    }]
  }
  # Choose one of the above CNI to install.
  install_cilium           = true
  install_calico           = false
  cluster_cidr             = "10.42.0.0/16"
  service_cluster_ip_range = "10.43.0.0/16"
}
```

## Some considerations

`always_pull_images`: Enable [always pull images admission controler](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#alwayspullimages) in the api-server

`cilium_allocate_bpf`: Pre-allocation of map entries allows per-packet latency to be reduced, at the expense of up-front memory allocation for the entries in the maps. Set to `true` to optimize for latency. If this value is modified, then during the next Cilium startup connectivity may be temporarily disrupted for endpoints with active connections

`cilium_debug`: Sets to run Cilium in full debug mode, which enables verbose logging and configures BPF programs to emit more visibility events into the output of `cilium monitor`

`cilium_monitor`: This option enables coalescing of tracing events in `cilium monitor` to only include periodic updates from active flows, or any packets that involve an L4 connection state change. Valid options are `none`, `low`, `medium`, `maximum`

`nodes`: A map of objects containing a list of node names and a IPs for each type (See: [yagan byoi example](https://github.com/bennu/terraform-byoi-yagan/tree/updating#yagan-byoi)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| nodes | A map of objects containing a list of node names and a IPs for each type | `any` | n/a | yes |
| private_key | Default private ssh key for nodes | `any` | n/a | yes |
| addon_job_timeout | Timeout for addons deployment in seconds | `number` | `120` | no |
| addons_include | URLs and/or local files to deploy withing RKE bootstrapping process | `list` | `[]` | no |
| always_pull_images | Enable always pull images admission controler | `bool` | `true` | no |
| api_server_lb | List of IPs on loadbalancer in front of kube-api-sever(s) | `list` | `[]` | no |
| cgroup_driver | Driver that the kubelet uses to manipulate cgroups on the host | `string` | `"cgroupfs"` | no |
| cilium_allocate_bpf | Pre-allocation of map entries allows per-packet latency to be reduced | `bool` | `false` | no |
| cilium_debug | Sets to run Cilium in full debug mode | `bool` | `true` | no |
| cilium_ipam | IPAM method to use for kubernetes cluster | `string` | `"kubernetes"` | no |
| cilium_monitor | This option enables coalescing of tracing events | `string` | `"maximum"` | no |
| cilium_node_init | Initialize nodes for cilium | `bool` | `false` | no |
| cilium_operator_prometheus_enabled | Create service monitor for prometheus operator to use | `bool` | `true` | no |
| cilium_operator_replicas | Replicas to create for cilium operator | `number` | `2` | no |
| cilium_prometheus_enabled | Add annotations to pods for prometheus to monitor | `bool` | `true` | no |
| cilium_psp_enabled | Create PodSecurityPolicies for cilium pods | `bool` | `true` | no |
| cilium_require_ipv4_pod_cidr | Requier Pod cidr to allocate pod IPs | `bool` | `true` | no |
| cilium_service_monitor_enabled | Create service monitor for cilium | `bool` | `true` | no |
| cilium_tunnel | Encapsulation tunnel to use | `string` | `"vxlan"` | no |
| cloud_provider | Cloud provider to deploy | `string` | `"none"` | no |
| cloud_provider_vsphere_in_tree | vSphere Cloud Provider in-tree configuration, list of maps | `list(map(string))` | `[]` | no |
| cluster_cidr | Cluster CIDR for pods IP allocation | `string` | `"10.42.0.0/16"` | no |
| cluster_domain | Domain for cluster-wide service discovery | `string` | `"cluster.local"` | no |
| delete_local_data_on_drain | Delete local data on node drain | `bool` | `true` | no |
| dns_provider | Cluster DNS service provider | `string` | `"coredns"` | no |
| drain_grace_period | Grace period to wait for node to drain | `string` | `"-1"` | no |
| drain_on_upgrade | Do drain operations on upgrades | `bool` | `true` | no |
| drain_timeout | Time to wait for node to drain | `number` | `60` | no |
| enable_cri_dockerd | Enable/Disable CRI dockerd for kubelet (Required on K8s v1.24+) | `bool` | `true` | no |
| enforce_node_allocatable | Enforce allocatable resources | `string` | `"pods,system-reserved,kube-reserved"` | no |
| etcd_backup_interval_hours | Interval hours for etcd backups | `number` | `8` | no |
| etcd_backup_retention | Amount of backups to keep in parallel | `number` | `6` | no |
| etcd_extra_args | A map of extra args for etcd | `map` | `{}` | no |
| etcd_extra_binds | A list of host volumes to bind to etcd | `list` | `[]` | no |
| etcd_extra_env | A list of env vars to prepend to etcd | `list` | `[]` | no |
| etcd_s3_access_key | S3 account access key for storing etcd backups | `string` | `""` | no |
| etcd_s3_bucket_name | S3 bucket for storing etcd backups | `string` | `""` | no |
| etcd_s3_endpoint | Endpoint for S3 and S3 compatible services for storing etcd backups | `string` | `""` | no |
| etcd_s3_folder | S3 folder for storing etcd backups | `string` | `""` | no |
| etcd_s3_region | S3 region for storing etcd backups | `string` | `"us-east-1"` | no |
| etcd_s3_secret_key | S3 account secret for storing etcd backups | `string` | `""` | no |
| eviction_hard | Params for eviction | `string` | `"memory.available<15%,nodefs.available<10%,nodefs.inodesFree<5%,imagefs.available<15%,imagefs.inodesFree<20%"` | no |
| fail_swap_on | Do not allow to deploy kubernetes on systems with swap partitions enabled | `bool` | `true` | no |
| force_drain | Force drain on upgrades | `bool` | `true` | no |
| generate_serving_certificate | Generate serving certificate | `bool` | `true` | no |
| hubble_enabled | Enable hubble | `bool` | `true` | no |
| hubble_metrics | Metrics to be fetched by hubble | `string` | `"{dns,drop,tcp,flow,port-distribution,icmp,http}"` | no |
| hubble_relay_enabled | Enable hubble releay | `bool` | `true` | no |
| hubble_ui_enabled | Enable hubble UI | `bool` | `true` | no |
| ignore_daemon_sets_on_drain | Drain despite of daemonset | `bool` | `true` | no |
| ignore_docker_version | Do not check docker version when deploying RKE | `bool` | `true` | no |
| ingress_provider | Deploy RKE built-in ingress controller | `string` | `"none"` | no |
| install_argocd | Decides if Argo CD operator must be installed after the cluster is deployed | `bool` | `false` | no |
| install_calico | Decides if Calico CNI must be installed | `bool` | `false` | no |
| install_cilium | Decides if Cilium CNI must be installed | `bool` | `true` | no |
| kube_api_extra_binds | A list of host volumes to bind to api-server | `list` | `[]` | no |
| kube_api_extra_env | A list of env vars to prepend to api-server | `list` | `[]` | no |
| kube_controller_extra_args | A map of extra args for controller | `map` | `{}` | no |
| kube_controller_extra_binds | A list of host volumes to bind to controller | `list` | `[]` | no |
| kube_controller_extra_env | A list of env vars to prepend to controller | `list` | `[]` | no |
| kube_reserved | Resources reserved for kubernetes pods | `string` | `"cpu=300m,memory=500Mi"` | no |
| kube_reserved_cgroup | Cgroup for kubernetes pods | `string` | `"/podruntime.slice"` | no |
| kubelet_extra_args | A map of extra args for kubelet | `map` | `{}` | no |
| kubelet_extra_binds | A list of host volumes to bind to kubelet | `list` | `[]` | no |
| kubelet_extra_env | A list of env vars to prepend to kubelet | `list` | `[]` | no |
| kubeproxy_extra_args | A map of extra args for kube-proxy | `map` | `{}` | no |
| kubeproxy_extra_binds | A list of host volumes to bind to kube-proxy | `list` | `[]` | no |
| kubeproxy_extra_env | A list of env vars to prepend to kube-proxy | `list` | `[]` | no |
| kubernetes_version | RKE version to deploy | `string` | `""` | no |
| max_pods | Max ammount of pods to deploy per node | `number` | `32` | no |
| monitoring | Monitoring service for kubernetes | `string` | `"metrics-server"` | no |
| node_cidr_mask_size | Mask size to assign to each node based on cluster_cidr | `number` | `26` | no |
| node_monitor_grace_period | Grace period for node monitoring | `string` | `"15s"` | no |
| node_monitor_period | Period time for node monitoring | `string` | `"2s"` | no |
| node_status_update_frequency | Frequency to report node status to api-server | `string` | `"4s"` | no |
| node_user | Default user to connect to nodes as | `string` | `"sles"` | no |
| pod_eviction_timeout | n/a | `string` | `"30s"` | no |
| pod_security_policy | Deploy a permissive default set of PSP | `bool` | `false` | no |
| registry_activate | Able to activate registry server | `bool` | `false` | no |
| registry_password | Password access for Registry server | `string` | `""` | no |
| registry_url | Registry URL for images | `string` | `""` | no |
| registry_username | Username access for Registry server | `string` | `""` | no |
| resource_naming | An arbitrary name can be prepend to resources. If not set, a random prefix will be created instead | `string` | `""` | no |
| rke_authorization | RKE authorization mode | `string` | `"rbac"` | no |
| sans | An alternative subject alternate name (SAN) list for api-server tls certs | `list` | `[]` | no |
| scheduler_extra_args | A map of extra args for scheduler | `map` | `{}` | no |
| scheduler_extra_binds | A list of host volumes to bind to scheduler | `list` | `[]` | no |
| scheduler_extra_env | A list of env vars to prepend to scheduler | `list` | `[]` | no |
| service_cluster_ip_range | CIDR for services allocation | `string` | `"10.43.0.0/16"` | no |
| service_node_port_range | Range for nodeport allocation | `string` | `"30000-32767"` | no |
| system_reserved | Resources reserved for system tasks | `string` | `"cpu=700m,memory=1Gi"` | no |
| system_reserved_cgroup | Cgroup for system tasks | `string` | `"/system.slice"` | no |
| upgrade_max_unavailable_controlplane | Max ammount of controlplane nodes that can be unavailable during upgrades | `string` | `"1"` | no |
| upgrade_max_unavailable_worker | Max ammount of worker nodes that can be unavailable during upgrades | `string` | `"10%"` | no |
| vsphere_cluster_id | vSphere cluster ID | `string` | `""` | no |
| vsphere_datacenter | vSphere datacenter | `string` | `""` | no |
| vsphere_insecure_flag | Do not verify tls cert | `bool` | `true` | no |
| vsphere_password | vSphere password | `string` | `""` | no |
| vsphere_port | vSphere port | `number` | `443` | no |
| vsphere_server | vSphere server | `string` | `""` | no |
| vsphere_username | vSphere username | `string` | `""` | no |
| write_cluster_yaml | Save rke cluster yaml to a file | `bool` | `false` | no |
| write_kubeconfig | Save kubeconfig to a file | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| api_server_url | Kubernetes api-server endpoint |
| ca_crt | Kubernetes CA certificate |
| client_cert | Kubernetes client certificate |
| client_key | Kubernetes client key |
| cluster | Kubernetes cluster object |
| cluster_name | Kubernetes cluster name |
| kube_admin_user | Kubernetes admin user |
| kubeconfig | Kubernetes admin kubeconfig |
