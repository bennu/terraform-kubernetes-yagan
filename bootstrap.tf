resource rke_cluster cluster {
  cluster_name          = local.cluster_name
  ignore_docker_version = var.ignore_docker_version
  kubernetes_version    = local.kubernetes_version

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
    provider = var.ingress_provider
  }

  dns {
    provider = var.dns_provider
  }

  monitoring {
    provider = var.monitoring
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

  dynamic nodes {
    for_each = flatten(
      [
        for type, node in var.nodes : [
          for n in node : {
            ip     = n.ip
            name   = n.name
            role   = type
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
      role              = [nodes.value.role]
      ssh_key           = var.private_key
      user              = var.node_user

      dynamic taints {
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

  # kubernetes services

  ## etcd
  services {
    etcd {
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
}

resource local_file kube_cluster_yaml {
  # Workaround: https://github.com/rancher/rke/issues/705
  count             = var.write_kubeconfig ? 1 : 0
  file_permission   = "0644"
  filename          = format("%s/%s", path.root, "kube_config_cluster.yml")
  sensitive_content = replace(rke_cluster.cluster.kube_config_yaml, local.api_access_regex, local.api_access)
}

resource local_file cluster_yaml {
  count             = var.write_cluster_yaml ? 1 : 0
  file_permission   = "0644"
  filename          = format("%s/%s", path.root, "cluster.yml")
  sensitive_content = rke_cluster.cluster.rke_cluster_yaml
}

resource helm_release cilium {
  depends_on = [local_file.kube_cluster_yaml, rke_cluster.cluster]
  name       = "cilium"
  atomic     = true
  repository = "https://helm.cilium.io"
  chart      = "cilium"
  version    = local.cilium_version
  namespace  = "kube-system"
  set {
    name  = "hubble.metrics.enabled"
    value = var.hubble_metrics
  }
  values = [
    yamlencode(
      {
        bpf = {
          monitorAggregation = var.cilium_monitor
          preallocateMaps    = var.cilium_allocate_bpf
          waitForMount       = var.cilium_wait_bfp
        }
        cluster = {
          name = local.cluster_name
        }
        debug = {
          enabled = var.cilium_debug
        }
        ipam = {
          mode = var.cilium_ipam
        }
        hubble = {
          enabled       = var.hubble_enabled
          listenAddress = ":4244"
          relay = {
            enabled = var.hubble_relay_enabled
          }
          ui = {
            enabled = var.hubble_ui_enabled
          }
        }
        k8s = {
          requireIPv4PodCIDR = var.cilium_require_ipv4_pod_cidr
        }
        nodeinit = {
          enabled           = var.cilium_node_init
          priorityClassName = "system-cluster-critical"
        }
        operator = {
          numReplicas       = var.cilium_operator_replicas
          priorityClassName = "system-cluster-critical"
        }
        priorityClassName = "system-cluster-critical"
        prometheus = {
          enabled = var.cilium_prometheus_enabled
        }
        tunnel = var.cilium_tunnel
      }
    )
  ]
}
