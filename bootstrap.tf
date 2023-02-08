resource "rke_cluster" "cluster" {
  depends_on            = [null_resource.node_cleanup]
  cluster_name          = local.cluster_name
  ignore_docker_version = var.ignore_docker_version
  kubernetes_version    = local.kubernetes_version
  enable_cri_dockerd    = var.enable_cri_dockerd

  authentication {
    strategy = "x509"
    sans     = local.sans
  }

  authorization {
    mode = var.rke_authorization
  }

  network {
    plugin = local.network_plugin
  }

  ingress {
    provider     = var.ingress_provider
    http_port    = 80
    https_port   = 443
    network_mode = "hostPort"
  }

  dns {
    provider = var.dns_provider
  }

  monitoring {
    provider = var.install_cilium ? "none" : var.monitoring
  }

  addon_job_timeout = var.addon_job_timeout
  addons_include    = var.addons_include

  private_registries {
    url        = var.registry_url
    user       = var.registry_username
    password   = var.registry_password
    is_default = var.registry_activate
  }

  upgrade_strategy {
    drain                        = var.drain_on_upgrade
    max_unavailable_controlplane = var.upgrade_max_unavailable_controlplane
    max_unavailable_worker       = var.upgrade_max_unavailable_worker

    drain_input {
      delete_local_data  = var.delete_local_data_on_drain
      force              = var.force_drain
      grace_period       = var.drain_grace_period
      ignore_daemon_sets = var.ignore_daemon_sets_on_drain
      timeout            = var.drain_timeout
    }
  }

  dynamic "nodes" {
    for_each = flatten(
      [
        for name, node in var.nodes : [
          for n in node : {
            ip     = n.ip
            name   = name
            role   = n.type
            labels = can(n.labels) ? n.labels : {}
            taints = can(n.taints) ? n.taints : []
          }
        ]
      ]
    )

    content {
      address           = nodes.value.ip
      hostname_override = nodes.value.name
      internal_address  = nodes.value.ip
      labels            = nodes.value.labels
      node_name         = nodes.value.name
      role              = nodes.value.role
      ssh_key           = var.private_key
      user              = var.node_user

      dynamic "taints" {
        for_each = flatten(
          [
            for taint in nodes.value.taints : {
              key    = lookup(taint, "key", "")
              value  = lookup(taint, "value", "")
              effect = lookup(taint, "effect", "")
            }
          ]
        )

        content {
          key    = taints.value.key
          value  = taints.value.value
          effect = taints.value.effect
        }
      }
    }
  }

  # Cloud Provider vSphere In-tree
  dynamic "cloud_provider" {
    for_each = var.cloud_provider_vsphere_in_tree
    content {
      name = lookup(cloud_provider.value, "type", null)
      vsphere_cloud_provider {
        virtual_center {
          name        = lookup(cloud_provider.value, "server_name", null)
          user        = lookup(cloud_provider.value, "user", null)
          password    = lookup(cloud_provider.value, "password", null)
          port        = lookup(cloud_provider.value, "port", null)
          datacenters = lookup(cloud_provider.value, "datacenters", null)
        }
        workspace {
          datacenter        = lookup(cloud_provider.value, "datacenters", null)
          server            = lookup(cloud_provider.value, "server_name", null)
          default_datastore = lookup(cloud_provider.value, "default_datastore", null)
          folder            = lookup(cloud_provider.value, "folder", null)
          resourcepool_path = lookup(cloud_provider.value, "resourcepool_path", null)
        }
        global {
          insecure_flag = lookup(cloud_provider.value, "insecure_flag", null)
        }
      }
    }
  }

  # kubernetes services

  services {
    ## etcd
    dynamic "etcd" {
      for_each = var.external_etcd ? [1] : []
      content {
        extra_args  = local.etcd_extra_args
        extra_binds = var.etcd_extra_binds
        extra_env   = var.etcd_extra_env

        backup_config {
          interval_hours = var.etcd_backup_interval_hours
          retention      = var.etcd_backup_retention

          s3_backup_config {
            access_key  = var.etcd_s3_access_key
            bucket_name = var.etcd_s3_bucket_name
            endpoint    = var.etcd_s3_endpoint
            folder      = var.etcd_s3_folder
            region      = var.etcd_s3_region
            secret_key  = var.etcd_s3_secret_key
          }
        }
      }
    }

    ## api-server
    kube_api {
      always_pull_images       = var.always_pull_images
      extra_args               = var.kube_api_extra_args
      extra_binds              = var.kube_api_extra_binds
      extra_env                = var.kube_api_extra_env
      pod_security_policy      = var.pod_security_policy
      service_cluster_ip_range = var.service_cluster_ip_range
      service_node_port_range  = var.service_node_port_range
      audit_log {
        enabled = true

        configuration {
          format     = "json"
          max_age    = 30
          max_backup = 5
          max_size   = 10
          path       = "/var/log/kube-audit/audit-log.json"
          policy = jsonencode(
            {
              apiVersion = "audit.k8s.io/v1"
              kind       = "Policy"
              rules = [
                {
                  level = "Metadata"
                },
              ]
            }
          )
        }
      }
      secrets_encryption_config {
        enabled = true
      }
    }

    ## controller
    kube_controller {
      cluster_cidr             = var.cluster_cidr
      extra_args               = local.kube_controller_extra_args
      extra_binds              = var.kube_controller_extra_binds
      extra_env                = var.kube_controller_extra_env
      service_cluster_ip_range = var.service_cluster_ip_range
    }

    ## kubelet
    kubelet {
      cluster_dns_server           = cidrhost(var.service_cluster_ip_range, 10)
      cluster_domain               = var.cluster_domain
      extra_args                   = local.kubelet_extra_args
      extra_binds                  = var.kubelet_extra_binds
      extra_env                    = var.kubelet_extra_env
      fail_swap_on                 = var.fail_swap_on
      generate_serving_certificate = var.generate_serving_certificate
    }

    ## kube-proxy
    kubeproxy {
      extra_args  = local.kubeproxy_extra_args
      extra_binds = var.kubeproxy_extra_binds
      extra_env   = var.kubeproxy_extra_env
    }

    ## scheduler
    scheduler {
      extra_args  = var.scheduler_extra_args
      extra_binds = var.scheduler_extra_binds
      extra_env   = var.scheduler_extra_env
    }
  }
  lifecycle {
    ignore_changes = [services]
  }
}

resource "local_sensitive_file" "kube_cluster_yaml" {
  # Workaround: https://github.com/rancher/rke/issues/705
  count           = var.write_kubeconfig ? 1 : 0
  file_permission = "0600"
  filename        = format("%s/%s", path.root, "kube_config_cluster.yaml")
  content         = replace(rke_cluster.cluster.kube_config_yaml, local.api_access_regex, local.api_access)
}

resource "local_sensitive_file" "cluster_yaml" {
  count           = var.write_cluster_yaml ? 1 : 0
  file_permission = "0644"
  filename        = format("%s/%s", path.root, "cluster.yaml")
  content         = rke_cluster.cluster.rke_cluster_yaml
}

resource "helm_release" "cilium" {
  count            = var.install_cilium ? 1 : 0
  depends_on       = [local_sensitive_file.kube_cluster_yaml, rke_cluster.cluster]
  name             = "cilium"
  repository       = "https://helm.cilium.io"
  chart            = "cilium"
  version          = local.cilium_version
  namespace        = "cilium"
  create_namespace = true
  timeout          = 300
  atomic           = true
  set {
    name  = "hubble.metrics.enabled"
    value = var.hubble_metrics
  }
  values = [
    yamlencode(
      {
        debug = {
          enabled = var.cilium_debug
        }
        cluster = {
          name = local.cluster_name
        }
        priorityClassName = "system-cluster-critical"
        bpf = {
          monitorAggregation = var.cilium_monitor
          preallocateMaps    = var.cilium_allocate_bpf
        }
        hubble = {
          enabled       = var.hubble_enabled
          relay = {
            enabled = var.hubble_relay_enabled
          }
          ui = {
            enabled = var.hubble_ui_enabled
          }
        }
        ipam = {
          mode = var.cilium_ipam
        }
        ipv6 = {
          enabled = false
        }
        k8s = {
          requireIPv4PodCIDR = var.cilium_require_ipv4_pod_cidr
        }
        prometheus = {
          enabled = var.cilium_prometheus_enabled
        }
        tunnel = var.cilium_tunnel
        operator = {
          numReplicas       = var.cilium_operator_replicas
          priorityClassName = "system-cluster-critical"
        }
        nodeinit = {
          enabled           = var.cilium_node_init
          priorityClassName = "system-cluster-critical"
        }
      }
    )
  ]
}

resource "helm_release" "calico" {
  count            = var.install_calico ? 1 : 0
  depends_on       = [local_sensitive_file.kube_cluster_yaml, rke_cluster.cluster]
  name             = "calico"
  repository       = "https://docs.tigera.io/calico/charts"
  chart            = "tigera-operator"
  version          = local.calico_version
  namespace        = "tigera-operator"
  create_namespace = true
  timeout          = 300
  atomic           = true
  values = [
    yamlencode({
      installation = {
        cni = {
          type = "Calico"
          ipam = {
            type = "Calico"
          }
        }
        calicoNetwork = {
          bgp = "Disabled"
          ipPools = [{
            cidr          = var.cluster_cidr
            encapsulation = "VXLAN"
            natOutgoing   = "Enabled"
            nodeSelector  = "all()"
            blockSize     = var.node_cidr_mask_size
          }]
        }
      }
    })
  ]
}

resource "helm_release" "metrics_server" {
  count      = var.install_cilium ? 1 : 0
  depends_on = [helm_release.cilium, helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = local.metrics_server_version
  namespace  = "kube-system"
  timeout    = 240
  values = [
    yamlencode({
      hostNetwork = {
        enabled = true
      }
    })
  ]
}

resource "helm_release" "argocd" {
  count            = var.install_argocd ? 1 : 0
  depends_on       = [helm_release.cilium, helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = local.argocd_version
  namespace        = "argo-cd"
  create_namespace = true
  timeout          = 240
  set {
    name  = "server.extraArgs"
    value = "{--insecure,--request-timeout='5m'}"
  }
}

resource "null_resource" "node_cleanup" {
  for_each = var.nodes
  triggers = {
    node_user   = var.node_user
    private_key = var.private_key
    node_name   = each.key
    node_ip     = each.value[0].ip
  }
  connection {
    user        = self.triggers.node_user
    host        = self.triggers.node_ip
    private_key = self.triggers.private_key
  }

  provisioner "file" {
    when        = destroy
    source      = "${path.module}/files/rkecleanup.bash"
    destination = "/tmp/cleanup.bash"
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "chmod +x /tmp/cleanup.bash && /tmp/cleanup.bash -f -i", "shutdown -r"
    ]
  }
}