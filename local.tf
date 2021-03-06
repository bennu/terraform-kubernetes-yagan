locals {
  api_access       = format("https://%s", length(var.sans) > 0 ? var.sans[0] : length(var.api_server_lb) > 0 ? var.api_server_lb[0] : rke_cluster.cluster.api_server_url)
  api_access_regex = "/https://\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}:6443/"
  cluster_name     = format("k8s-cluster-%s", local.resource_naming)
  etcd_extra_args  = merge({ election-timeout = "5000", heartbeat-interval = "500" }, var.etcd_extra_args)
  kube_controller_extra_args = merge(
    {
      allocate-node-cidrs       = true
      node-cidr-mask-size       = var.node_cidr_mask_size
      node-monitor-grace-period = var.node_monitor_grace_period
      node-monitor-period       = var.node_monitor_period
      pod-eviction-timeout      = var.pod_eviction_timeout
    },
  var.kube_controller_extra_args)
  kubelet_extra_args = merge(
    {
      # enforce-node-allocatable     = var.enforce_node_allocatable
      # kube-reserved                = var.kube_reserved
      # kube-reserved-cgroup         = var.kube_reserved_cgroup
      # system-reserved              = var.system_reserved
      # system-reserved-cgroup       = var.system_reserved_cgroup
      allowed-unsafe-sysctls       = "net.*"
      cgroup-driver                = var.cgroup_driver
      eviction-hard                = var.eviction_hard
      max-pods                     = var.max_pods
      node-status-update-frequency = var.node_status_update_frequency
    },
  var.kubelet_extra_args)
  kubeproxy_extra_args = merge(
    {
      ipvs-scheduler  = "rr"
      ipvs-strict-arp = true
      proxy-mode      = "ipvs"
    },
  var.kubeproxy_extra_args)
  network_plugin  = "none"
  resource_naming = length(random_string.resource_naming) == 0 ? var.resource_naming : random_string.resource_naming.0.result
  sans            = compact(concat(var.sans, var.api_server_lb))

  # versions
  cilium_version      = "1.9.1"
  kubernetes_version  = var.kubernetes_version != "" ? var.kubernetes_version : local.rke_version
  rke_version         = "v1.19.4-rancher1-1"
  vsphere_cpi_version = "gcr.io/cloud-provider-vsphere/cpi/release/manager:v1.2.1"
}
