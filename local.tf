locals {
  api_access       = length(var.sans) > 0 ? format("https://%s:6443", var.sans[0]) : length(var.api_server_lb) > 0 ? format("https://%s:6443", var.api_server_lb[0]) : rke_cluster.cluster.api_server_url
  api_access_regex = "/https://\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}:6443/"
  cluster_name     = var.cluster_name == "" ? format("k8s-cluster-%s", local.resource_naming) : var.cluster_name
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
      allowed-unsafe-sysctls       = "net.*"
      cgroup-driver                = var.cgroup_driver
      eviction-hard                = var.eviction_hard
      max-pods                     = var.max_pods
      node-status-update-frequency = var.node_status_update_frequency
    },
  var.kubelet_extra_args)
  kubeproxy_extra_args = merge(local.kubeproxy_mode
    ,
  var.kubeproxy_extra_args)
  network_plugin = "none"

  kubeproxy_mode = var.support_version == "v1.24.17-rancher1-1" ? {
    ipvs-scheduler  = "rr"
    ipvs-strict-arp = true
    proxy-mode      = "ipvs"
    } : {
    proxy-mode = "iptables"

  }

  resource_naming = length(random_string.resource_naming) == 0 ? var.resource_naming : random_string.resource_naming.0.result
  sans            = compact(concat(var.sans, var.api_server_lb))

  ccm_serviceType = var.support_version == "v1.24.17-rancher1-1" ? "NodePort" : "ClusterIP"

  # versions
  addons_version      = lookup(var.addons_version, var.support_version, {})
  calico_version      = lookup(local.addons_version, "calico_version", "")
  argocd_version      = lookup(local.addons_version, "argocd_version", "")
  kubernetes_version  = lookup(local.addons_version, "rke_version", "")
  vsphere_cpi_version = lookup(local.addons_version, "vsphere_cpi_version", "")
  install_cp_vsphere  = var.cloud_provider == "vsphere" ? 1 : 0



}