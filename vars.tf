# kubernetes
variable "addon_job_timeout" {
  description = "Timeout for addons deployment in seconds"
  default     = 120
}
variable "addons_include" {
  description = "URLs and/or local files to deploy withing RKE bootstrapping process"
  default     = []
}
variable "always_pull_images" {
  description = "Enable always pull images admission controler"
  default     = true
}
variable "api_server_lb" {
  description = "List of IPs on loadbalancer in front of kube-api-sever(s)"
  default     = []
}
variable "cgroup_driver" {
  description = "Driver that the kubelet uses to manipulate cgroups on the host"
  default     = "cgroupfs"
}
variable "cilium_allocate_bpf" {
  description = "Pre-allocation of map entries allows per-packet latency to be reduced"
  default     = false
}
variable "cilium_debug" {
  description = "Sets to run Cilium in full debug mode"
  default     = true
}
variable "cilium_ipam" {
  description = "IPAM method to use for kubernetes cluster"
  default     = "kubernetes"
}
variable "cilium_monitor" {
  description = "This option enables coalescing of tracing events"
  default     = "maximum"
}
variable "cilium_node_init" {
  description = "Initialize nodes for cilium"
  default     = false
}
variable "cilium_node_init_restart_pods" {
  description = "Restart pods not managed by cilium"
  default     = true
}
variable "cilium_operator_prometheus_enabled" {
  description = "Create service monitor for prometheus operator to use"
  default     = true
}
variable "cilium_operator_replicas" {
  description = "Replicas to create for cilium operator"
  default     = 2
}
variable "cilium_prometheus_enabled" {
  description = "Add annotations to pods for prometheus to monitor"
  default     = true
}
variable "cilium_psp_enabled" {
  description = "Create PodSecurityPolicies for cilium pods"
  default     = true
}
variable "cilium_require_ipv4_pod_cidr" {
  description = "Requier Pod cidr to allocate pod IPs"
  default     = true
}
variable "cilium_service_monitor_enabled" {
  description = "Create service monitor for cilium"
  default     = true
}
variable "cilium_tunnel" {
  description = "Encapsulation tunnel to use"
  default     = "vxlan"
}
variable "cilium_wait_bfp" {
  description = "Wait for BPF to be present in order to work"
  default     = true
}
variable "cloud_provider" {
  description = "Cloud provider to deploy"
  default     = "none"
}
variable "cluster_cidr" {
  description = "Cluster CIDR for pods IP allocation"
  default     = "10.42.0.0/16"
}
variable "cluster_domain" {
  description = "Domain for cluster-wide service discovery"
  default     = "cluster.local"
}
variable "delete_local_data_on_drain" {
  description = "Delete local data on node drain"
  default     = true
}
variable "dns_provider" {
  description = "Cluster DNS service provider"
  default     = "coredns"
}
variable "dns_upstream_nameservers" {
  description = "DNS upstream nameservers for external query"
  default     = []
}
variable "drain_grace_period" {
  description = "Grace period to wait for node to drain"
  default     = "-1"
}
variable "drain_on_upgrade" {
  description = "Do drain operations on upgrades"
  default     = true
}
variable "drain_timeout" {
  description = "Time to wait for node to drain"
  default     = 60
}
variable "enforce_node_allocatable" {
  description = "Enforce allocatable resources"
  default     = "pods,system-reserved,kube-reserved"
}
variable "etcd_backup_interval_hours" {
  description = "Interval hours for etcd backups"
  default     = 8
}
variable "etcd_backup_retention" {
  description = "Amount of backups to keep in parallel"
  default     = 6
}
variable "etcd_extra_args" {
  description = "A map of extra args for etcd"
  default     = {}
}
variable "etcd_extra_binds" {
  description = "A list of host volumes to bind to etcd"
  default     = []
}
variable "etcd_extra_env" {
  description = "A list of env vars to prepend to etcd"
  default     = []
}
variable "etcd_s3_access_key" {
  description = "S3 account access key for storing etcd backups"
  default     = ""
}
variable "etcd_s3_bucket_name" {
  description = "S3 bucket for storing etcd backups"
  default     = ""
}
variable "etcd_s3_endpoint" {
  description = "Endpoint for S3 and S3 compatible services for storing etcd backups"
  default     = ""
}
variable "etcd_s3_folder" {
  description = "S3 folder for storing etcd backups"
  default     = ""
}
variable "etcd_s3_region" {
  description = "S3 region for storing etcd backups"
  default     = "us-east-1"
}
variable "etcd_s3_secret_key" {
  description = "S3 account secret for storing etcd backups"
  default     = ""
}
variable "eviction_hard" {
  description = "Params for eviction"
  default     = "memory.available<15%,nodefs.available<10%,nodefs.inodesFree<5%,imagefs.available<15%,imagefs.inodesFree<20%"
}
variable "fail_swap_on" {
  description = "Do not allow to deploy kubernetes on systems with swap partitions enabled"
  default     = true
}
variable "force_drain" {
  description = "Force drain on upgrades"
  default     = true
}
variable "generate_serving_certificate" {
  description = "Generate serving certificate"
  default     = true
}
variable "hubble_enabled" {
  description = "Enable hubble"
  default     = true
}
variable "hubble_metrics" {
  description = "Metrics to be fetched by hubble"
  default     = "{dns,drop,tcp,flow,port-distribution,icmp,http}"
}
variable "hubble_relay_enabled" {
  description = "Enable hubble releay"
  default     = true
}
variable "hubble_ui_enabled" {
  description = "Enable hubble UI"
  default     = true
}
variable "ignore_daemon_sets_on_drain" {
  description = "Drain despite of daemonset"
  default     = true
}
variable "ignore_docker_version" {
  description = "Do not check docker version when deploying RKE"
  default     = true
}
variable "ingress_provider" {
  description = "Deploy RKE built-in ingress controller"
  default     = "none"
}
variable "kube_api_extra_args" {
  description = "A map of extra args for api-server"
  default     = {}
}
variable "kube_api_extra_binds" {
  description = "A list of host volumes to bind to api-server"
  default     = []
}
variable "kube_api_extra_env" {
  description = "A list of env vars to prepend to api-server"
  default     = []
}
variable "kube_controller_extra_args" {
  description = "A map of extra args for controller"
  default     = {}
}
variable "kube_controller_extra_binds" {
  description = "A list of host volumes to bind to controller"
  default     = []
}
variable "kube_controller_extra_env" {
  description = "A list of env vars to prepend to controller"
  default     = []
}
variable "kube_reserved" {
  description = "Resources reserved for kubernetes pods"
  default     = "cpu=300m,memory=500Mi"
}
variable "kube_reserved_cgroup" {
  description = "Cgroup for kubernetes pods"
  default     = "/podruntime.slice"
}
variable "kubelet_extra_args" {
  description = "A map of extra args for kubelet"
  default     = {}
}
variable "kubelet_extra_binds" {
  description = "A list of host volumes to bind to kubelet"
  default     = []
}
variable "kubelet_extra_env" {
  description = "A list of env vars to prepend to kubelet"
  default     = []
}
variable "kubeproxy_extra_args" {
  description = "A map of extra args for kube-proxy"
  default     = {}
}
variable "kubeproxy_extra_binds" {
  description = "A list of host volumes to bind to kube-proxy"
  default     = []
}
variable "kubeproxy_extra_env" {
  description = "A list of env vars to prepend to kube-proxy"
  default     = []
}
variable "kubernetes_version" {
  description = "RKE version to deploy"
  default     = ""
}
variable "max_pods" {
  description = "Max ammount of pods to deploy per node"
  default     = 32
}
variable "monitoring" {
  description = "Monitoring service for kubernetes"
  default     = "metrics-server"
}
variable "node_cidr_mask_size" {
  description = "Mask size to assign to each node based on cluster_cidr"
  default     = 26
}
variable "node_monitor_grace_period" {
  description = "Grace period for node monitoring"
  default     = "15s"
}
variable "node_monitor_period" {
  description = "Period time for node monitoring"
  default     = "2s"
}
variable "node_status_update_frequency" {
  description = "Frequency to report node status to api-server"
  default     = "4s"
}
variable "node_user" {
  description = "Default user to connect to nodes as"
  default     = "sles"
}
variable "nodes" {
  description = "A map of objects containing a list of node names and a IPs for each type"
}
variable "pod_eviction_timeout" {
  default = "30s"
}
variable "pod_security_policy" {
  description = "Deploy a permissive default set of PSP"
  default     = false
}
variable "private_key" {
  description = "Default private ssh key for nodes"
}
variable "resource_naming" {
  description = "An arbitrary name can be prepend to resources. If not set, a random prefix will be created instead"
  default     = ""
}
variable "rke_authorization" {
  description = "RKE authorization mode"
  default     = "rbac"
}
variable "sans" {
  description = "An alternative subject alternate name (SAN) list for api-server tls certs"
  default     = []
}
variable "scheduler_extra_args" {
  description = "A map of extra args for scheduler"
  default     = {}
}
variable "scheduler_extra_binds" {
  description = "A list of host volumes to bind to scheduler"
  default     = []
}
variable "scheduler_extra_env" {
  description = "A list of env vars to prepend to scheduler"
  default     = []
}
variable "service_cluster_ip_range" {
  description = "CIDR for services allocation"
  default     = "10.43.0.0/16"
}
variable "service_node_port_range" {
  description = "Range for nodeport allocation"
  default     = "30000-32767"
}
variable "system_reserved" {
  description = "Resources reserved for system tasks"
  default     = "cpu=700m,memory=1Gi"
}
variable "system_reserved_cgroup" {
  description = "Cgroup for system tasks"
  default     = "/system.slice"
}
variable "upgrade_max_unavailable_controlplane" {
  description = "Max ammount of controlplane nodes that can be unavailable during upgrades"
  default     = "1"
}
variable "upgrade_max_unavailable_worker" {
  description = "Max ammount of worker nodes that can be unavailable during upgrades"
  default     = "10%"
}
variable "write_cluster_yaml" {
  description = "Save rke cluster yaml to a file"
  default     = false
}
variable "write_kubeconfig" {
  description = "Save kubeconfig to a file"
  default     = true
}

# registry configuration
variable "registry_url" {
  description = "Registry URL for images"
  default     = ""
}
variable "registry_username" {
  description = "Username access for Registry server"
  default     = ""
}
variable "registry_password" {
  description = "Password access for Registry server"
  default     = ""
}
variable "registry_activate" {
  description = "Able to activate registry server"
  default     = false
}

# vsphere cloud provider

variable "vsphere_username" {
  description = "vSphere username"
  default     = ""
}
variable "vsphere_port" {
  description = "vSphere port"
  default     = 443
}
variable "vsphere_insecure_flag" {
  description = "Do not verify tls cert"
  default     = true
}
variable "vsphere_password" {
  description = "vSphere password"
  default     = ""
}
variable "vsphere_server" {
  description = "vSphere server"
  default     = ""
}
variable "vsphere_datacenter" {
  description = "vSphere datacenter"
  default     = ""
}
variable "vsphere_cluster_id" {
  description = "vSphere cluster ID"
  default     = ""
}

# vsphere cloud provider
variable "cloud_provider_vsphere_in_tree" {
  description = "vSphere Cloud Provider in-tree configuration, list of maps"
  type        = list(map(string))
  default     = []
}
