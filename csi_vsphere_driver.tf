
locals {
  check_rancher1_24 = var.support_version == "v1.24.4-rancher1-1" ? true : false
  check_rancher1_19 = var.support_version == "v1.19.16-rancher2-1" ? true : false

  csi_controller_rules_maps = {
    "v1.19.16-rancher2-1" = [
      {
        "verbs"      = ["get", "list", "watch"]
        "api_groups" = [""]
        "resources"  = ["nodes", "pods", "persistentvolumeclaims", "configmaps"]
      }

      , {
        "verbs"      = ["patch"]
        "api_groups" = [""]
        "resources"  = ["persistentvolumeclaims/status"]
      }

      , {
        "verbs"      = ["get", "list", "watch", "create", "update", "delete", "patch"]
        "api_groups" = [""]
        "resources"  = ["persistentvolumes"]
      }

      , {
        "verbs"      = ["get", "list", "watch", "create", "update", "patch"]
        "api_groups" = [""]
        "resources"  = ["events"]
      }

      , {
        "verbs"      = ["get", "list", "watch", "create", "update", "patch"]
        "api_groups" = ["coordination.k8s.io"]
        "resources"  = ["leases"]
      }

      , {
        "verbs"      = ["get", "list", "watch"]
        "api_groups" = ["storage.k8s.io"]
        "resources"  = ["storageclasses", "csinodes"]
      }

      , {
        "verbs"      = ["get", "list", "watch", "patch"]
        "api_groups" = ["storage.k8s.io"]
        "resources"  = ["volumeattachments"]
      }

      , {
        "verbs"      = ["create", "get", "update", "watch", "list"]
        "api_groups" = ["cns.vmware.com"]
        "resources"  = ["triggercsifullsyncs"]
      }

      , {
        "verbs"      = ["create", "get", "list", "watch", "update", "delete"]
        "api_groups" = ["cns.vmware.com"]
        "resources"  = ["cnsvspherevolumemigrations"]
      }

      , {
        "verbs"      = ["get", "create", "update"]
        "api_groups" = ["apiextensions.k8s.io"]
        "resources"  = ["customresourcedefinitions"]
      }

      , {
        "verbs"      = ["patch"]
        "api_groups" = ["storage.k8s.io"]
        "resources"  = ["volumeattachments/status"]
      }
    ]
    "v1.24.4-rancher1-1" = [
      {
        "verbs"      = ["get", "list", "watch"]
        "api_groups" = [""]
        "resources"  = ["nodes", "pods", "configmaps"]
      }

      , {
        "verbs"      = ["get", "list", "watch", "update"]
        "api_groups" = [""]
        "resources"  = ["persistentvolumeclaims"]
      }

      , {
        "verbs"      = ["patch"]
        "api_groups" = [""]
        "resources"  = ["persistentvolumeclaims/status"]
      }

      , {
        "verbs"      = ["get", "list", "watch", "create", "update", "delete", "patch"]
        "api_groups" = [""]
        "resources"  = ["persistentvolumes"]
      }

      , {
        "verbs"      = ["get", "list", "watch", "create", "update", "patch"]
        "api_groups" = [""]
        "resources"  = ["events"]
      }

      , {
        "verbs"      = ["get", "watch", "list", "delete", "update", "create"]
        "api_groups" = ["coordination.k8s.io"]
        "resources"  = ["leases"]
      }

      , {
        "verbs"      = ["get", "list", "watch"]
        "api_groups" = ["storage.k8s.io"]
        "resources"  = ["storageclasses", "csinodes"]
      }

      , {
        "verbs"      = ["get", "list", "watch", "patch"]
        "api_groups" = ["storage.k8s.io"]
        "resources"  = ["volumeattachments"]
      }

      , {
        "verbs"      = ["create", "get", "update", "watch", "list"]
        "api_groups" = ["cns.vmware.com"]
        "resources"  = ["triggercsifullsyncs"]
      }

      , {
        "verbs"      = ["create", "get", "list", "watch", "update", "delete"]
        "api_groups" = ["cns.vmware.com"]
        "resources"  = ["cnsvspherevolumemigrations"]
      }

      , {
        "verbs"      = ["get", "create", "update"]
        "api_groups" = ["apiextensions.k8s.io"]
        "resources"  = ["customresourcedefinitions"]
      }

      , {
        "verbs"      = ["patch"]
        "api_groups" = ["storage.k8s.io"]
        "resources"  = ["volumeattachments/status"]
      }

      , {
        "verbs"      = ["create", "get", "list", "update", "delete"]
        "api_groups" = ["cns.vmware.com"]
        "resources"  = ["cnsvolumeoperationrequests"]
      }

      , {
        "verbs"      = ["get", "list"]
        "api_groups" = ["snapshot.storage.k8s.io"]
        "resources"  = ["volumesnapshots"]
      }

      , {
        "verbs"      = ["watch", "get", "list"]
        "api_groups" = ["snapshot.storage.k8s.io"]
        "resources"  = ["volumesnapshotclasses"]
      }

      , {
        "verbs"      = ["create", "get", "list", "watch", "update", "delete", "patch"]
        "api_groups" = ["snapshot.storage.k8s.io"]
        "resources"  = ["volumesnapshotcontents"]
      }

      , {
        "verbs"      = ["update", "patch"]
        "api_groups" = ["snapshot.storage.k8s.io"]
        "resources"  = ["volumesnapshotcontents/status"]
      }

      , {
        "verbs"      = ["get", "update", "watch", "list"]
        "api_groups" = ["cns.vmware.com"]
        "resources"  = ["csinodetopologies"]
      }
    ]
  }

  vsphere_csi_internal_feature_state_data_maps = {
    "v1.19.16-rancher2-1" = {
      "csi-migration"            = "false"
      "csi-auth-check"           = "true"
      "online-volume-extend"     = "true"
      "trigger-csi-fullsync"     = "false"
      "async-query-volume"       = "false"
      "improved-csi-idempotency" = "false"
      "improved-volume-topology" = "false"

    },
    "v1.24.4-rancher1-1" = {
      "csi-migration"                     = "false"
      "csi-auth-check"                    = "true"
      "online-volume-extend"              = "true"
      "trigger-csi-fullsync"              = "false"
      "async-query-volume"                = "true"
      "improved-csi-idempotency"          = "true"
      "improved-volume-topology"          = "true"
      "block-volume-snapshot"             = "true"
      "csi-windows-support"               = "false"
      "use-csinode-id"                    = "true"
      "list-volumes"                      = "false"
      "pv-to-backingdiskobjectid-mapping" = "false"
      "cnsmgr-suspend-create-volume"      = "false"
      "topology-preferential-datastores"  = "true"
      "max-pvscsi-targets-per-vm"         = "false"
    }
  }

  vsphere_csi_controller_images_maps = {
    "v1.19.16-rancher2-1" = {
      "csi-attacher"           = "k8s.gcr.io/sig-storage/csi-attacher:v3.2.0",
      "csi-resizer"            = "quay.io/k8scsi/csi-resizer:v1.1.0",
      "vsphere-csi-controller" = "gcr.io/cloud-provider-vsphere/csi/release/driver:v2.3.2",
      "liveness-probe"         = "quay.io/k8scsi/livenessprobe:v2.2.0",
      "vsphere-syncer"         = "gcr.io/cloud-provider-vsphere/csi/release/syncer:v2.3.2",
      "csi-provisioner"        = "k8s.gcr.io/sig-storage/csi-provisioner:v2.2.0"

    },
    "v1.24.4-rancher1-1" = {
      "csi-attacher"           = "k8s.gcr.io/sig-storage/csi-attacher:v3.4.0",
      "csi-resizer"            = "k8s.gcr.io/sig-storage/csi-resizer:v1.4.0",
      "vsphere-csi-controller" = "gcr.io/cloud-provider-vsphere/csi/release/driver:v2.6.2",
      "liveness-probe"         = "k8s.gcr.io/sig-storage/livenessprobe:v2.7.0",
      "vsphere-syncer"         = "gcr.io/cloud-provider-vsphere/csi/release/syncer:v2.6.2",
      "csi-provisioner"        = "k8s.gcr.io/sig-storage/csi-provisioner:v3.2.1"
      "csi-snapshotter"        = "k8s.gcr.io/sig-storage/csi-snapshotter:v5.0.1"

    }
  }

  vsphere_csi_node_images_maps = {
    "v1.19.16-rancher2-1" = {

      "node-driver-registrar_img"  = "quay.io/k8scsi/csi-node-driver-registrar:v2.1.0"
      "node-driver-registrar_args" = ["--v=5", "--csi-address=$(ADDRESS)", "--kubelet-registration-path=$(DRIVER_REG_SOCK_PATH)", "--health-port=9809"]

      "vsphere-csi-node" = "gcr.io/cloud-provider-vsphere/csi/release/driver:v2.3.2"
      "liveness-probe"   = "k8s.gcr.io/sig-storage/livenessprobe:v2.2.0"
    },
    "v1.24.4-rancher1-1" = {

      "node-driver-registrar_img"  = "k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.5.1"
      "node-driver-registrar_args" = ["--v=5", "--csi-address=$(ADDRESS)", "--kubelet-registration-path=$(DRIVER_REG_SOCK_PATH)"]

      "vsphere-csi-node" = "gcr.io/cloud-provider-vsphere/csi/release/driver:v2.6.2"
      "liveness-probe"   = "k8s.gcr.io/sig-storage/livenessprobe:v2.7.0"

    }
  }


  csi_controller_rules                    = lookup(local.csi_controller_rules_maps, var.support_version, {})
  vsphere_csi_node_rules                  = lookup(local.csi_controller_rules_maps, var.support_version, {})
  vsphere_csi_internal_feature_state_data = lookup(local.vsphere_csi_internal_feature_state_data_maps, var.support_version, {})
  vsphere_csi_controller_images           = lookup(local.vsphere_csi_controller_images_maps, var.support_version, {})
  vsphere_csi_node_images                 = lookup(local.vsphere_csi_node_images_maps, var.support_version, {})

}


#cambiar este  cluster rol
resource "kubernetes_cluster_role" "vsphere_csi_node_cluster_role" {
  count = local.install_cp_vsphere
  metadata {
    name = "vsphere-csi-node-cluster-role"
  }
  rule {
    api_groups = ["cns.vmware.com"]
    resources  = local.check_rancher1_24 ? ["csinodetopologies"] : [""]
    verbs      = ["create", "watch", "get", "patch"]

  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get"]
  }

}

resource "kubernetes_cluster_role" "vsphere_csi_controller_role" {
  count      = local.install_cp_vsphere
  depends_on = [helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name = "vsphere-csi-controller-role"
  }

  dynamic "rule" {
    for_each = local.csi_controller_rules
    content {
      verbs      = rule.value["verbs"]
      api_groups = rule.value["api_groups"]
      resources  = rule.value["resources"]
    }
  }
}

resource "kubernetes_config_map" "vsphere_csi_internal_feature_states" {
  count      = local.install_cp_vsphere
  depends_on = [helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name      = "internal-feature-states.csi.vsphere.vmware.com"
    namespace = kubernetes_namespace.vsphere_csi_namespace.0.metadata.0.name
  }
  data = local.vsphere_csi_internal_feature_state_data
}

resource "kubernetes_deployment" "vsphere_csi_controller" {
  count = local.install_cp_vsphere

  # 
  depends_on = [helm_release.calico, kubernetes_daemonset.vsphere_cloud_controller_manager[0], local_sensitive_file.kube_cluster_yaml]

  metadata {
    name      = "vsphere-csi-controller"
    namespace = kubernetes_namespace.vsphere_csi_namespace.0.metadata.0.name
  }

  spec {
    replicas = local.check_rancher1_24 ? 3 : 1

    dynamic "strategy" {
      for_each = local.check_rancher1_24 ? [1] : []
      content {
        type = "RollingUpdate"

        rolling_update {
          max_unavailable = 1
          max_surge       = 0
        }

      }
    }

    selector {
      match_labels = {
        app = "vsphere-csi-controller"
      }
    }

    template {
      metadata {
        labels = {
          app  = "vsphere-csi-controller"
          role = "vsphere-csi"
        }
      }

      spec {
        service_account_name            = kubernetes_service_account.vsphere_csi_controller.0.metadata.0.name
        automount_service_account_token = true

        toleration {
          key      = "node-role.kubernetes.io/master"
          operator = "Exists"
          effect   = "NoSchedule"
        }

        toleration {
          key      = "node-role.kubernetes.io/control-plane"
          operator = "Exists"
          effect   = "NoSchedule"
        }

        dns_policy = "Default"

        container {
          name  = "csi-attacher"
          image = local.vsphere_csi_controller_images["csi-attacher"]
          args  = ["--v=4", "--timeout=300s", "--csi-address=$(ADDRESS)", "--leader-election", "--kube-api-qps=100", "--kube-api-burst=100"]

          env {
            name  = "ADDRESS"
            value = "/csi/csi.sock"
          }

          volume_mount {
            name       = "socket-dir"
            mount_path = "/csi"
          }
        }

        container {
          name  = "csi-resizer"
          image = local.vsphere_csi_controller_images["csi-resizer"]
          args  = ["--v=4", "--timeout=300s", "--handle-volume-inuse-error=false", "--csi-address=$(ADDRESS)", "--kube-api-qps=100", "--kube-api-burst=100", "--leader-election"]

          env {
            name  = "ADDRESS"
            value = "/csi/csi.sock"
          }

          volume_mount {
            name       = "socket-dir"
            mount_path = "/csi"
          }
        }

        container {
          name              = "vsphere-csi-controller"
          image             = local.vsphere_csi_controller_images["vsphere-csi-controller"]
          args              = ["--fss-name=internal-feature-states.csi.vsphere.vmware.com", "--fss-namespace=$(CSI_NAMESPACE)"]
          image_pull_policy = "Always"

          env {
            name  = "CSI_ENDPOINT"
            value = "unix:///csi/csi.sock"
          }

          env {
            name  = "X_CSI_MODE"
            value = "controller"
          }

          env {
            name  = "X_CSI_SPEC_DISABLE_LEN_CHECK"
            value = "true"
          }

          env {
            name  = "X_CSI_SERIAL_VOL_ACCESS_TIMEOUT"
            value = "3m"
          }

          env {
            name  = "VSPHERE_CSI_CONFIG"
            value = "/etc/cloud/csi-vsphere.conf"
          }

          env {
            name  = "LOGGER_LEVEL"
            value = "PRODUCTION"
          }

          env {
            name  = "INCLUSTER_CLIENT_QPS"
            value = "100"
          }

          env {
            name  = "INCLUSTER_CLIENT_BURST"
            value = "100"
          }

          env {
            name = "CSI_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          volume_mount {
            name       = "vsphere-config-volume"
            read_only  = true
            mount_path = "/etc/cloud"
          }

          volume_mount {
            name       = "socket-dir"
            mount_path = "/csi"
          }

          port {
            name           = "healthz"
            container_port = 9808
            protocol       = "TCP"
          }

          port {
            name           = "prometheus"
            container_port = 2112
            protocol       = "TCP"
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = "healthz"
            }

            initial_delay_seconds = 10
            timeout_seconds       = 3
            period_seconds        = 5
            failure_threshold     = 3
          }
        }

        container {
          name  = "liveness-probe"
          image = local.vsphere_csi_controller_images["liveness-probe"] #"k8s.gcr.io/sig-storage/livenessprobe:v2.7.0"
          args  = ["--v=4", "--csi-address=/csi/csi.sock"]

          volume_mount {
            name       = "socket-dir"
            mount_path = "/csi"
          }
        }

        container {
          name              = "vsphere-syncer"
          image             = local.vsphere_csi_controller_images["vsphere-syncer"] #"gcr.io/cloud-provider-vsphere/csi/release/syncer:v2.6.2"
          args              = ["--leader-election", "--fss-name=internal-feature-states.csi.vsphere.vmware.com", "--fss-namespace=$(CSI_NAMESPACE)"]
          image_pull_policy = "Always"

          port {
            name           = "prometheus"
            container_port = 2113
            protocol       = "TCP"
          }

          env {
            name  = "FULL_SYNC_INTERVAL_MINUTES"
            value = "30"
          }

          env {
            name  = "VSPHERE_CSI_CONFIG"
            value = "/etc/cloud/csi-vsphere.conf"
          }

          env {
            name  = "LOGGER_LEVEL"
            value = "PRODUCTION"
          }

          env {
            name  = "INCLUSTER_CLIENT_QPS"
            value = "100"
          }

          env {
            name  = "INCLUSTER_CLIENT_BURST"
            value = "100"
          }

          env {
            name = "CSI_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          volume_mount {
            name       = "vsphere-config-volume"
            read_only  = true
            mount_path = "/etc/cloud"
          }
        }

        container {
          name  = "csi-provisioner"
          image = local.vsphere_csi_controller_images["csi-provisioner"] #"k8s.gcr.io/sig-storage/csi-provisioner:v3.2.1"
          args  = ["--v=4", "--timeout=300s", "--csi-address=$(ADDRESS)", "--kube-api-qps=100", "--kube-api-burst=100", "--leader-election", "--default-fstype=ext4"]

          env {
            name  = "ADDRESS"
            value = "/csi/csi.sock"
          }

          volume_mount {
            name       = "socket-dir"
            mount_path = "/csi"
          }
        }


        dynamic "container" {
          for_each = local.check_rancher1_24 ? [1] : []
          content {
            name  = "csi-snapshotter"
            image = local.vsphere_csi_controller_images["csi-snapshotter"] #"k8s.gcr.io/sig-storage/csi-snapshotter:v5.0.1"
            args  = ["--v=4", "--kube-api-qps=100", "--kube-api-burst=100", "--timeout=300s", "--csi-address=$(ADDRESS)", "--leader-election"]

            env {
              name  = "ADDRESS"
              value = "/csi/csi.sock"
            }

            volume_mount {
              name       = "socket-dir"
              mount_path = "/csi"
            }

          }
        }

        volume {
          name = "vsphere-config-volume"

          secret {
            secret_name = kubernetes_secret.csi_vsphere_creds.0.metadata.0.name
          }
        }

        volume {
          name = "socket-dir"
          empty_dir {}
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_daemonset" "vsphere_csi_node" {
  count = local.install_cp_vsphere

  # 
  depends_on = [helm_release.calico, kubernetes_daemonset.vsphere_cloud_controller_manager[0], local_sensitive_file.kube_cluster_yaml]

  metadata {
    name      = "vsphere-csi-node"
    namespace = kubernetes_namespace.vsphere_csi_namespace.0.metadata.0.name
  }

  spec {
    selector {
      match_labels = {
        app = "vsphere-csi-node"
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_unavailable = 1
      }
    }

    template {
      metadata {
        labels = {
          app  = "vsphere-csi-node"
          role = "vsphere-csi"
        }
      }

      spec {
        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        automount_service_account_token = true
        service_account_name            = kubernetes_service_account.vsphere_csi_node.0.metadata.0.name

        host_network = true

        dns_policy = "ClusterFirstWithHostNet"

        container {
          name  = "node-driver-registrar"
          image = local.vsphere_csi_node_images["node-driver-registrar_img"] #"k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.5.1"
          args  = local.vsphere_csi_node_images["node-driver-registrar_args"] 

          env {
            name  = "ADDRESS"
            value = "/csi/csi.sock"
          }

          env {
            name  = "DRIVER_REG_SOCK_PATH"
            value = "/var/lib/kubelet/plugins/csi.vsphere.vmware.com/csi.sock"
          }

          volume_mount {
            name       = "plugin-dir"
            mount_path = "/csi"
          }

          volume_mount {
            name       = "registration-dir"
            mount_path = "/registration"
          }

          dynamic "port" {
            for_each = local.check_rancher1_19 ? [1] : []
            content {
              container_port = 9809
              name           = "healthz"
            }

          }

          dynamic "liveness_probe" {
            for_each = local.check_rancher1_24 ? [1] : []
            content {
              exec {
                command = ["/csi-node-driver-registrar", "--kubelet-registration-path=/var/lib/kubelet/plugins/csi.vsphere.vmware.com/csi.sock", "--mode=kubelet-registration-probe"]
              }
              initial_delay_seconds = 3
            }
          }


          dynamic "liveness_probe" {
            for_each = local.check_rancher1_19 ? [1] : []
            content {
              http_get {
                path = "/healthz"
                port = "healthz"
              }
              initial_delay_seconds = 5
              timeout_seconds       = 5
            }
          }

        }

        container {
          name              = "vsphere-csi-node"
          image             = local.vsphere_csi_node_images["vsphere-csi-node"] #"gcr.io/cloud-provider-vsphere/csi/release/driver:v2.6.2"
          args              = ["--fss-name=internal-feature-states.csi.vsphere.vmware.com", "--fss-namespace=$(CSI_NAMESPACE)"]
          image_pull_policy = "Always"

          env {
            name = "NODE_NAME"

            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          env {
            name  = "CSI_ENDPOINT"
            value = "unix:///csi/csi.sock"
          }

          env {
            name  = "X_CSI_MODE"
            value = "node"
          }

          env {
            name  = "X_CSI_SPEC_REQ_VALIDATION"
            value = "false"
          }

          env {
            name  = "X_CSI_SPEC_DISABLE_LEN_CHECK"
            value = "true"
          }

          env {
            name  = "LOGGER_LEVEL"
            value = "PRODUCTION"
          }

          env {
            name = "CSI_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          dynamic "env" {
            for_each = local.check_rancher1_24 ? [1] : []
            content {
              name  = "NODEGETINFO_WATCH_TIMEOUT_MINUTES"
              value = "1"
            }
          }

          security_context {
            capabilities {
              add = ["SYS_ADMIN"]
            }

            privileged                 = true
            allow_privilege_escalation = true
          }

          volume_mount {
            name       = "plugin-dir"
            mount_path = "/csi"
          }

          volume_mount {
            name              = "pods-mount-dir"
            mount_path        = "/var/lib/kubelet"
            mount_propagation = "Bidirectional"
          }

          volume_mount {
            name       = "device-dir"
            mount_path = "/dev"
          }

          volume_mount {
            name       = "blocks-dir"
            mount_path = "/sys/block"
          }

          volume_mount {
            name       = "sys-devices-dir"
            mount_path = "/sys/devices"
          }

          port {
            name           = "healthz"
            container_port = 9808
            protocol       = "TCP"
            host_port      = 9808
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = "healthz"
            }

            initial_delay_seconds = 10
            timeout_seconds       = 5
            period_seconds        = 5
            failure_threshold     = 3
          }
        }

        container {
          name  = "liveness-probe"
          image = local.vsphere_csi_node_images["liveness-probe"] #"k8s.gcr.io/sig-storage/livenessprobe:v2.7.0"
          args  = ["--v=4", "--csi-address=/csi/csi.sock"]

          volume_mount {
            name       = "plugin-dir"
            mount_path = "/csi"
          }
        }

        volume {
          name = "registration-dir"

          host_path {
            path = "/var/lib/kubelet/plugins_registry"
            type = "Directory"
          }
        }

        volume {
          name = "plugin-dir"

          host_path {
            path = "/var/lib/kubelet/plugins/csi.vsphere.vmware.com/"
            type = "DirectoryOrCreate"
          }
        }

        volume {
          name = "pods-mount-dir"

          host_path {
            path = "/var/lib/kubelet"
            type = "Directory"
          }
        }

        volume {
          name = "device-dir"

          host_path {
            path = "/dev"
          }
        }

        volume {
          name = "blocks-dir"

          host_path {
            path = "/sys/block"
            type = "Directory"
          }
        }

        volume {
          name = "sys-devices-dir"

          host_path {
            path = "/sys/devices"
            type = "Directory"
          }
        }

        toleration {
          operator = "Exists"
          effect   = "NoExecute"
        }

        toleration {
          operator = "Exists"
          effect   = "NoSchedule"
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [metadata]
  }
}
