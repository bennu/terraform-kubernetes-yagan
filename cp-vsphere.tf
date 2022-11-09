# vSphere Cloud Controller Manager
# https://raw.githubusercontent.com/kubernetes/cloud-provider-vsphere/release-1.23/releases/v1.23/vsphere-cloud-controller-manager.yaml

resource "kubernetes_service_account" "vsphere_cloud_controller_manager" {
  count      = var.cloud_provider == "vsphere" ? 1 : 0
  depends_on = [helm_release.cilium, helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name      = "cloud-controller-manager"
    namespace = "kube-system"
    labels = {
      vsphere-cpi-infra = "service-account"
      component         = "cloud-controller-manager"
    }
  }

  automount_service_account_token = true
}

resource "kubernetes_secret" "cpi_vsphere_creds" {
  count      = var.cloud_provider == "vsphere" ? 1 : 0
  depends_on = [helm_release.cilium, helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name      = "vsphere-cloud-secret"
    namespace = "kube-system"
    labels = {
      vsphere-cpi-infra = "secret"
      component         = "cloud-controller-manager"
    }
  }

  data = {
    format("%s.username", var.vsphere_server) = var.vsphere_username
    format("%s.password", var.vsphere_server) = var.vsphere_password
  }
  
  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_config_map" "cloud_config_vsphere" {
  count      = var.cloud_provider == "vsphere" ? 1 : 0
  depends_on = [helm_release.cilium, helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name      = "vsphere-cloud-config"
    namespace = "kube-system"
    labels = {
      vsphere-cpi-infra = "config"
      component         = "cloud-controller-manager"
    }
  }

  data = {
    "vsphere.conf" = yamlencode(
      {
        global = {
          port            = var.vsphere_port
          insecureFlag    = var.vsphere_insecure_flag
          secretName      = kubernetes_secret.cpi_vsphere_creds.0.metadata.0.name
          secretNamespace = kubernetes_secret.cpi_vsphere_creds.0.metadata.0.namespace
        }
        vcenter = {
          default = {
            server      = var.vsphere_server
            user        = var.vsphere_username
            password    = var.vsphere_password
            datacenters = [var.vsphere_datacenter]
          }
        }
      }
    )
  }
}

resource "kubernetes_role_binding" "vsphere_servicecatalog_apiserver_authentication_reader" {
  count      = var.cloud_provider == "vsphere" ? 1 : 0
  depends_on = [helm_release.cilium, helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name      = "servicecatalog.k8s.io:apiserver-authentication-reader"
    namespace = "kube-system"
    labels = {
      vsphere-cpi-infra = "role-binding"
      component         = "cloud-controller-manager"
    }
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vsphere_cloud_controller_manager.0.metadata.0.name
    namespace = kubernetes_service_account.vsphere_cloud_controller_manager.0.metadata.0.namespace
  }

  subject {
    api_group = ""
    kind      = "User"
    name      = "cloud-controller-manager"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "extension-apiserver-authentication-reader"
  }
}

resource "kubernetes_cluster_role_binding" "vsphere_system_cloud_controller_manager" {
  count      = var.cloud_provider == "vsphere" ? 1 : 0
  depends_on = [helm_release.cilium, helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name = "system:cloud-controller-manager"
    labels = {
      vsphere-cpi-infra = "role-binding"
      component         = "cloud-controller-manager"
    }
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vsphere_cloud_controller_manager.0.metadata.0.name      # "cloud-controller-manager" 
    namespace = kubernetes_service_account.vsphere_cloud_controller_manager.0.metadata.0.namespace # "kube-system"
  }

  subject {
    api_group = ""
    kind      = "User"
    name      = "cloud-controller-manager"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.vsphere_system_cloud_controller_manager.0.metadata.0.name # "system:cloud-controller-manager"
  }
}

resource "kubernetes_cluster_role" "vsphere_system_cloud_controller_manager" {
  count      = var.cloud_provider == "vsphere" ? 1 : 0
  depends_on = [helm_release.cilium, helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name = "system:cloud-controller-manager"
    labels = {
      vsphere-cpi-infra = "role"
      component         = "cloud-controller-manager"
    }
  }

  rule {
    verbs      = ["create", "patch", "update"]
    api_groups = [""]
    resources  = ["events"]
  }

  rule {
    verbs      = ["*"]
    api_groups = [""]
    resources  = ["nodes"]
  }

  rule {
    verbs      = ["patch"]
    api_groups = [""]
    resources  = ["nodes/status"]
  }

  rule {
    verbs      = ["list", "patch", "update", "watch"]
    api_groups = [""]
    resources  = ["services"]
  }

  rule {
    verbs      = ["patch"]
    api_groups = [""]
    resources  = ["services/status"]
  }

  rule {
    verbs      = ["create", "get", "list", "watch", "update"]
    api_groups = [""]
    resources  = ["serviceaccounts"]
  }

  rule {
    verbs      = ["get", "list", "update", "watch"]
    api_groups = [""]
    resources  = ["persistentvolumes"]
  }

  rule {
    verbs      = ["create", "get", "list", "watch", "update"]
    api_groups = [""]
    resources  = ["endpoints"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["secrets"]
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["get", "list", "watch", "create", "update"]
  }
}

resource "kubernetes_daemonset" "vsphere_cloud_controller_manager" {
  count      = var.cloud_provider == "vsphere" ? 1 : 0
  depends_on = [helm_release.cilium, helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name      = "vsphere-cloud-controller-manager"
    namespace = "kube-system"
    labels = {
      component = "cloud-controller-manager"
      tier      = "control-plane"
    }
  }

  spec {
    selector {
      match_labels = {
        name = "vsphere-cloud-controller-manager"
      }
    }

    strategy {
      type = "RollingUpdate"
    }

    template {
      metadata {
        labels = {
          name      = "vsphere-cloud-controller-manager"
          component = "cloud-controller-manager"
          tier      = "control-plane"
        }
      }

      spec {
        toleration {
          key    = "node.cloudprovider.kubernetes.io/uninitialized"
          value  = "true"
          effect = "NoSchedule"
        }

        toleration {
          key      = "node-role.kubernetes.io/master"
          operator = "Exists"
          effect   = "NoSchedule"
        }

        # toleration {
        #   key      = "node.kubernetes.io/not-ready"
        #   operator = "Exists"
        #   effect   = "NoSchedule"
        # }

        security_context {
          run_as_user = 1001
        }

        automount_service_account_token = true
        service_account_name            = kubernetes_service_account.vsphere_cloud_controller_manager.0.metadata.0.name

        priority_class_name = "system-node-critical"

        container {
          name  = "vsphere-cloud-controller-manager"
          image = local.vsphere_cpi_version
          args  = ["--v=2", "--cloud-provider=vsphere", "--cloud-config=/etc/cloud/vsphere.conf"]

          resources {
            requests = {
              cpu = "200m"
            }
          }

          volume_mount {
            name       = "vsphere-config-volume"
            read_only  = true
            mount_path = "/etc/cloud"
          }
        }

        host_network = true

        volume {
          name = "vsphere-config-volume"
          config_map {
            name = kubernetes_config_map.cloud_config_vsphere.0.metadata.0.name
          }
        }
      }
    }
  }
}

# 

resource "kubernetes_namespace" "vsphere_csi_namespace" {
  count      = var.cloud_provider == "vsphere" ? 1 : 0
  depends_on = [helm_release.cilium, helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name = "vmware-system-csi"
  }
  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_secret" "csi_vsphere_creds" {
  count      = var.cloud_provider == "vsphere" ? 1 : 0
  depends_on = [helm_release.cilium, helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name      = "vsphere-config-secret"
    namespace = kubernetes_namespace.vsphere_csi_namespace.0.metadata.0.name
  }

  data = {
    "csi-vsphere.conf" = <<EOF
[Global]
cluster-id = "${var.vsphere_cluster_id}"

[VirtualCenter "${var.vsphere_server}"]
insecure-flag = ${var.vsphere_insecure_flag}
user = "${var.vsphere_username}"
password = "${var.vsphere_password}"
port = "${var.vsphere_port}"
datacenters = "${var.vsphere_datacenter}"
    EOF
  }
  lifecycle {
    ignore_changes = [metadata]
  }
}

# vSphere CSI Driver
# https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/v2.6.0/manifests/vanilla/vsphere-csi-driver.yaml

resource "kubernetes_csi_driver_v1" "vsphere_csi_vmware_com" {
  count      = var.cloud_provider == "vsphere" ? 1 : 0
  depends_on = [helm_release.cilium, helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name = "csi.vsphere.vmware.com"
  }

  spec {
    attach_required        = true
    pod_info_on_mount      = false
    volume_lifecycle_modes = ["Persistent"]
  }
}

resource "kubernetes_service_account" "vsphere_csi_controller" {
  count      = var.cloud_provider == "vsphere" ? 1 : 0
  depends_on = [helm_release.cilium, helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name      = "vsphere-csi-controller"
    namespace = kubernetes_namespace.vsphere_csi_namespace.0.metadata.0.name
  }
  automount_service_account_token = true
}

resource "kubernetes_cluster_role" "vsphere_csi_controller_role" {
  count      = var.cloud_provider == "vsphere" ? 1 : 0
  depends_on = [helm_release.cilium, helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name = "vsphere-csi-controller-role"
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["nodes", "pods", "configmaps"]
  }

  rule {
    verbs      = ["get", "list", "watch", "update"]
    api_groups = [""]
    resources  = ["persistentvolumeclaims"]
  }

  rule {
    verbs      = ["patch"]
    api_groups = [""]
    resources  = ["persistentvolumeclaims/status"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "update", "delete", "patch"]
    api_groups = [""]
    resources  = ["persistentvolumes"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "update", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }

  rule {
    verbs      = ["get", "watch", "list", "delete", "update", "create"]
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses", "csinodes"]
  }

  rule {
    verbs      = ["get", "list", "watch", "patch"]
    api_groups = ["storage.k8s.io"]
    resources  = ["volumeattachments"]
  }

  rule {
    verbs      = ["create", "get", "update", "watch", "list"]
    api_groups = ["cns.vmware.com"]
    resources  = ["triggercsifullsyncs"]
  }

  rule {
    verbs      = ["create", "get", "list", "watch", "update", "delete"]
    api_groups = ["cns.vmware.com"]
    resources  = ["cnsvspherevolumemigrations"]
  }

  rule {
    verbs      = ["get", "create", "update"]
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
  }

  rule {
    verbs      = ["patch"]
    api_groups = ["storage.k8s.io"]
    resources  = ["volumeattachments/status"]
  }

  rule {
    verbs      = ["create", "get", "list", "update", "delete"]
    api_groups = ["cns.vmware.com"]
    resources  = ["cnsvolumeoperationrequests"]
  }

  rule {
    verbs      = ["get", "list"]
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshots"]
  }

  rule {
    verbs      = ["watch", "get", "list"]
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshotclasses"]
  }

  rule {
    verbs      = ["create", "get", "list", "watch", "update", "delete", "patch"]
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshotcontents"]
  }

  rule {
    verbs      = ["update", "patch"]
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshotcontents/status"]
  }

  rule {
    verbs      = ["get", "update", "watch", "list"]
    api_groups = ["cns.vmware.com"]
    resources  = ["csinodetopologies"]
  }
}

resource "kubernetes_cluster_role_binding" "vsphere_csi_controller_binding" {
  count = var.cloud_provider == "vsphere" ? 1 : 0
  metadata {
    name = "vsphere-csi-controller-binding"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vsphere_csi_controller.0.metadata.0.name
    namespace = kubernetes_namespace.vsphere_csi_namespace.0.metadata.0.name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.vsphere_csi_controller_role.0.metadata.0.name
  }
}

resource "kubernetes_service_account" "vsphere_csi_node" {
  count      = var.cloud_provider == "vsphere" ? 1 : 0
  depends_on = [helm_release.cilium, helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name      = "vsphere-csi-node"
    namespace = kubernetes_namespace.vsphere_csi_namespace.0.metadata.0.name
  }
  automount_service_account_token = true
}

resource "kubernetes_cluster_role" "vsphere_csi_node" {
  count      = var.cloud_provider == "vsphere" ? 1 : 0
  depends_on = [helm_release.cilium, helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name = "vsphere-csi-node"
  }

  rule {
    verbs      = ["create", "watch", "get", "patch"]
    api_groups = ["cns.vmware.com"]
    resources  = ["csinodetopologies"]
  }

  rule {
    verbs      = ["get"]
    api_groups = [""]
    resources  = ["nodes"]
  }
}

resource "kubernetes_cluster_role_binding" "vsphere_csi_node_cluster_role_binding" {
  count      = var.cloud_provider == "vsphere" ? 1 : 0
  depends_on = [helm_release.cilium, helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name = "vsphere-csi-node-cluster-role-binding"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vsphere_csi_node.0.metadata.0.name
    namespace = kubernetes_namespace.vsphere_csi_namespace.0.metadata.0.name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.vsphere_csi_node.0.metadata.0.name
  }
}

resource "kubernetes_role" "vsphere_csi_node" {
  count      = var.cloud_provider == "vsphere" ? 1 : 0
  depends_on = [helm_release.cilium, helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name      = "vsphere-csi-node-role"
    namespace = kubernetes_namespace.vsphere_csi_namespace.0.metadata.0.name
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["configmaps"]
  }
}

resource "kubernetes_role_binding" "vsphere_csi_node_binding" {
  count      = var.cloud_provider == "vsphere" ? 1 : 0
  depends_on = [helm_release.cilium, helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name      = "vsphere-csi-node-binding"
    namespace = kubernetes_namespace.vsphere_csi_namespace.0.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vsphere_csi_node.0.metadata.0.name
    namespace = kubernetes_namespace.vsphere_csi_namespace.0.metadata.0.name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.vsphere_csi_node.0.metadata.0.name
  }
}

resource "kubernetes_config_map" "vsphere_csi_internal_feature_states" {
  count      = var.cloud_provider == "vsphere" ? 1 : 0
  depends_on = [helm_release.cilium, helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name      = "internal-feature-states.csi.vsphere.vmware.com"
    namespace = kubernetes_namespace.vsphere_csi_namespace.0.metadata.0.name
  }
  data = {
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

resource "kubernetes_service" "vsphere_cloud_controller_manager" {
  count      = var.cloud_provider == "vsphere" ? 1 : 0
  depends_on = [helm_release.cilium, helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name      = "vsphere-csi-controller"
    namespace = kubernetes_namespace.vsphere_csi_namespace.0.metadata.0.name

    labels = {
      app = "vsphere-csi-controller"
    }
  }

  spec {
    port {
      name        = "ctlr"
      protocol    = "TCP"
      port        = 2112
      target_port = 2112
    }
    port {
      name        = "syncer"
      port        = 2113
      target_port = 2113
      protocol    = "TCP"
    }

    selector = {
      app = "vsphere-csi-controller"
    }

    type = "NodePort"
  }
}

resource "kubernetes_deployment" "vsphere_csi_controller" {
  count      = var.cloud_provider == "vsphere" ? 1 : 0
  depends_on = [helm_release.cilium, helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name      = "vsphere-csi-controller"
    namespace = kubernetes_namespace.vsphere_csi_namespace.0.metadata.0.name
  }

  spec {
    replicas = 1

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_unavailable = 1
        max_surge       = 0
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
          image = "k8s.gcr.io/sig-storage/csi-attacher:v3.4.0"
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
          image = "k8s.gcr.io/sig-storage/csi-resizer:v1.4.0"
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
          image             = "gcr.io/cloud-provider-vsphere/csi/release/driver:v2.6.0"
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
          image = "k8s.gcr.io/sig-storage/livenessprobe:v2.7.0"
          args  = ["--v=4", "--csi-address=/csi/csi.sock"]

          volume_mount {
            name       = "socket-dir"
            mount_path = "/csi"
          }
        }

        container {
          name              = "vsphere-syncer"
          image             = "gcr.io/cloud-provider-vsphere/csi/release/syncer:v2.6.0"
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
          image = "k8s.gcr.io/sig-storage/csi-provisioner:v3.2.1"
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

        container {
          name  = "csi-snapshotter"
          image = "k8s.gcr.io/sig-storage/csi-snapshotter:v5.0.1"
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
  count      = var.cloud_provider == "vsphere" ? 1 : 0
  depends_on = [helm_release.cilium, helm_release.calico, local_sensitive_file.kube_cluster_yaml]
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
          image = "k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.5.1"
          args  = ["--v=5", "--csi-address=$(ADDRESS)", "--kubelet-registration-path=$(DRIVER_REG_SOCK_PATH)"]

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

          liveness_probe {
            exec {
              command = ["/csi-node-driver-registrar", "--kubelet-registration-path=/var/lib/kubelet/plugins/csi.vsphere.vmware.com/csi.sock", "--mode=kubelet-registration-probe"]
            }
            initial_delay_seconds = 3
          }
        }

        container {
          name              = "vsphere-csi-node"
          image             = "gcr.io/cloud-provider-vsphere/csi/release/driver:v2.6.0"
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

          env {
            name  = "NODEGETINFO_WATCH_TIMEOUT_MINUTES"
            value = "1"
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
          image = "k8s.gcr.io/sig-storage/livenessprobe:v2.7.0"
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
