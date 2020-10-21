# Rancher Kubernetes Engine

> Deploy RKE using terraform. This module is meant to work with [`read-vsphere`](../../read-vsphere/README.md)

**Note:** This module uses cilium as only CNI plugin, as such it is deployed in `ipvs` mode.

## Customizing

### kubernetes

|Variable|Description|Required|Default|
|:---|---|:---:|:---|
|`addon_job_timeout`|Timeout for addons deployment in seconds||`120`|
|`addons_include`|URLs and/or local files to deploy withing RKE bootstrapping process||`[]`|
|`always_pull_images`|Enable [always pull images admission controler](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#alwayspullimages) in the api-server||`true`|
|`api_server_lb`|External (floating) IP if using a loadbalancer in front of the `api-server`. (e.g. Openstack floating IP)|||
|`api_server_vip`|Internal (virtual) IP if using a loadbalancer in front of the `api-server`. (e.g. Openstack virtual IP for LBs)|||
|`bastion_ip`|Bastion IP for RKE bootstrapping|X||
|`cilium_allocate_bpf`|Pre-allocation of map entries allows per-packet latency to be reduced, at the expense of up-front memory allocation for the entries in the maps. Set to `true` to optimize for latency. If this value is modified, then during the next Cilium startup connectivity may be temporarily disrupted for endpoints with active connections||`true`|
|`cilium_debug`|Sets to run Cilium in full debug mode, which enables verbose logging and configures BPF programs to emit more visibility events into the output of `cilium monitor`||`true`|
|`cilium_monitor`|This option enables coalescing of tracing events in `cilium monitor` to only include periodic updates from active flows, or any packets that involve an L4 connection state change. Valid options are `none`, `low`, `medium`, `maximum`||`maximum`|
|`cluster_cidr`|Cluster CIDR for pods allocation||`10.42.0.0/16`|
|`cluster_domain`|Domain for cluster-wide service discovery||`cluster.local`|
|`dns_provider`|Cluster DNS service provider||`coredns`|
|`etcd_backup_interval_hours`|Interval hours for `etcd` backups||`8`|
|`etcd_backup_retention`|Amount of backups to keep in parallel||`6`|
|`etcd_extra_args`|A map of extra args for `etcd`||`{ election-timeout = "5000", heartbeat-interval = "500" }`|
|`etcd_extra_binds`|A list of host volumes to bind to `etcd`||`[]`|
|`etcd_extra_env`|A list of env vars to prepend to `etcd`||`[]`|
|`etcd_s3_access_key`|S3 account access key for storing `etcd` backups|||
|`etcd_s3_bucket_name`|S3 bucket for stroing `etcd` backups|||
|`etcd_s3_endpoint`|Endpoint for S3 and S3 compatible services for storing `etcd` backups|||
|`etcd_s3_region`|S3 region for storing `etcd` backups|||
|`etcd_s3_secret_key`|S3 account secret for storing `etcd` backups|||
|`fail_swap_on`|Do not allow to deploy kubernetes on systems with swap partitions enabled||`true`|
|`ignore_docker_version`|Do not check `docker` version when deploying RKE||`true`|
|`ingress_provider`|Deploy RKE built-in ingress controller||`none`|
|`kube_api_extra_args`|A map of extra args for `api-server`||`{ feature-gates = "APIResponseCompression=true" }`|
|`kube_api_extra_binds`|A list of host volumes to bind to `api-server`||`[]`|
|`kube_api_extra_env`|A list of env vars to prepend to `api-server`||`[]`|
|`kube_controller_extra_args`|A map of extra args for `controller`||`{}`|
|`kube_controller_extra_binds`|A list of host volumes to bind to `controller`||`[]`|
|`kube_controller_extra_env`|A list of env vars to prepend to `controller`||`[]`|
|`kubelet_extra_args`|A map of extra args for `kubelet`||`{ max-pods = 30 }`|
|`kubelet_extra_binds`|A list of host volumes to bind to `kubelet`||`[]`|
|`kubelet_extra_env`|A list of env vars to prepend to `kubelet`||`[]`|
|`kubeproxy_extra_args`|A map of extra args for `kube-proxy`||`{}`|
|`kubeproxy_extra_binds`|A list of host volumes to bind to `kube-proxy`||`[]`|
|`kubeproxy_extra_env`|A list of env vars to prepend to `kube-proxy`||`[]`|
|`kubernetes_version`|RKE version to deploy||`v1.15.3-rancher1-1`|
|`monitoring`|Monitoring service for kubernetes||`metrics-server`|
|`nodes`|A map of objects containing a list of node names and a IPs for each type (See: [nodes](../../openstack/instances/local.tf#L90))|X||
|`pod_security_policy`|Deploy a permissive default set of PSP||`false`|
|`private_key`|Private ssh key for nodes|X||
|`resource_naming`|An arbitrary name can be prepend to resources. If not set, a random prefix will be created instead|||
|`rke_authorization`|RKE authorization mode||`rbac`|
|`sans`|An alternative subject alternate name (SAN) list for `api-server` tls certs||`[]`|
|`scheduler_extra_args`|A map of extra args for `scheduler`||`{}`|
|`scheduler_extra_binds`|A list of host volumes to bind to `scheduler`||`[]`|
|`scheduler_extra_env`|A list of env vars to prepend to `scheduler`||`[]`|
|`service_cluster_ip_range`|CIDR for services allocation||`10.43.0.0/16`|
|`service_node_port_range`|Range for nodeport allocation||`30000-32767`|
|`write_kubeconfig`|Save kubeconfig to a file||`true`|
