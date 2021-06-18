# vSphere cloud provider
resource "kubernetes_secret" "cpi_vsphere_creds" {
  count = var.cloud_provider == "vsphere" ? 1 : 0
  metadata {
    name      = "cpi-vsphere-creds"
    namespace = "kube-system"
  }

  data = {
    format("%s.username", var.vsphere_server) = var.vsphere_username
    format("%s.password", var.vsphere_server) = var.vsphere_password
  }
}

resource "kubernetes_config_map" "cloud_config_vsphere" {
  count = var.cloud_provider == "vsphere" ? 1 : 0
  metadata {
    name      = "cloud-config"
    namespace = "kube-system"
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
            datacenters = [var.vsphere_datacenter]
          }
        }
      }
    )
  }
}

# https://github.com/kubernetes/cloud-provider-vsphere/blob/v1.2.1/manifests/controller-manager/cloud-controller-manager-roles.yaml
resource "kubernetes_cluster_role" "vsphere_system_cloud_controller_manager" {
  count = var.cloud_provider == "vsphere" ? 1 : 0
  metadata {
    name = "system:cloud-controller-manager"
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
}

# https://github.com/kubernetes/cloud-provider-vsphere/blob/v1.2.1/manifests/controller-manager/cloud-controller-manager-role-bindings.yaml

resource "kubernetes_role_binding" "vsphere_servicecatalog_apiserver_authentication_reader" {
  count = var.cloud_provider == "vsphere" ? 1 : 0
  metadata {
    name      = "servicecatalog.k8s.io:apiserver-authentication-reader"
    namespace = "kube-system"
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "cloud-controller-manager"
    namespace = "kube-system"
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
  count = var.cloud_provider == "vsphere" ? 1 : 0
  metadata {
    name = "system:cloud-controller-manager"
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "cloud-controller-manager"
    namespace = "kube-system"
  }

  subject {
    api_group = ""
    kind      = "User"
    name      = "cloud-controller-manager"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:cloud-controller-manager"
  }
}

# https://github.com/kubernetes/cloud-provider-vsphere/blob/v1.2.1/manifests/controller-manager/vsphere-cloud-controller-manager-ds.yaml

resource "kubernetes_service_account" "vsphere_cloud_controller_manager" {
  count = var.cloud_provider == "vsphere" ? 1 : 0
  metadata {
    name      = "cloud-controller-manager"
    namespace = "kube-system"
  }

  automount_service_account_token = true
}

resource "kubernetes_daemonset" "vsphere_cloud_controller_manager" {
  count = var.cloud_provider == "vsphere" ? 1 : 0
  metadata {
    name      = "vsphere-cloud-controller-manager"
    namespace = "kube-system"
    annotations = {
      "scheduler.alpha.kubernetes.io/critical-pod" = ""
    }

    labels = {
      component = "cloud-controller-manager"
      k8s-app   = "vsphere-cloud-controller-manager"
      tier      = "control-plane"
    }
  }

  spec {
    selector {
      match_labels = {
        k8s-app = "vsphere-cloud-controller-manager"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = "vsphere-cloud-controller-manager"
        }
      }

      spec {
        volume {
          name = "vsphere-config-volume"
          config_map {
            name = kubernetes_config_map.cloud_config_vsphere.0.metadata.0.name
          }
        }

        container {
          name  = "vsphere-cloud-controller-manager"
          image = local.vsphere_cpi_version
          args  = ["--v=2", "--cloud-provider=vsphere", "--cloud-config=/etc/cloud/vsphere.conf"]

          resources {
            requests {
              cpu = "200m"
            }
          }

          volume_mount {
            name       = "vsphere-config-volume"
            read_only  = true
            mount_path = "/etc/cloud"
          }
        }

        automount_service_account_token = true
        service_account_name            = kubernetes_service_account.vsphere_cloud_controller_manager.0.metadata.0.name
        host_network                    = true

        security_context {
          run_as_user = 1001
        }

        toleration {
          key    = "node.cloudprovider.kubernetes.io/uninitialized"
          value  = "true"
          effect = "NoSchedule"
        }

        toleration {
          key    = "node-role.kubernetes.io/master"
          effect = "NoSchedule"
        }

        toleration {
          key      = "node.kubernetes.io/not-ready"
          operator = "Exists"
          effect   = "NoSchedule"
        }
      }
    }

    strategy {
      type = "RollingUpdate"
    }
  }
}

resource "kubernetes_service" "vsphere_cloud_controller_manager" {
  count = var.cloud_provider == "vsphere" ? 1 : 0
  metadata {
    name      = "vsphere-cloud-controller-manager"
    namespace = "kube-system"

    labels = {
      component = "cloud-controller-manager"
    }
  }

  spec {
    port {
      protocol    = "TCP"
      port        = 43001
      target_port = "43001"
    }

    selector = {
      component = "cloud-controller-manager"
    }

    type = "NodePort"
  }
}

# vSphere cloud storage
resource "kubernetes_secret" "csi_vsphere_creds" {
  count = var.cloud_provider == "vsphere" ? 1 : 0
  metadata {
    name      = "csi-vsphere-creds"
    namespace = "kube-system"
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
}

# https://github.com/kubernetes-sigs/vsphere-csi-driver/blob/9a23359530264ecf792f5a7badfbb32b2b01be40/manifests/v2.0.1/vsphere-67u3/vanilla/rbac/vsphere-csi-controller-rbac.yaml

resource "kubernetes_service_account" "vsphere_csi_controller" {
  count = var.cloud_provider == "vsphere" ? 1 : 0
  metadata {
    name      = "vsphere-csi-controller"
    namespace = "kube-system"
  }
  automount_service_account_token = true
}

resource "kubernetes_cluster_role" "vsphere_csi_controller_role" {
  count = var.cloud_provider == "vsphere" ? 1 : 0
  metadata {
    name = "vsphere-csi-controller-role"
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["nodes", "pods"]
  }

  rule {
    verbs      = ["get", "list", "watch", "update"]
    api_groups = [""]
    resources  = ["persistentvolumeclaims"]
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
    verbs      = ["get", "list", "watch", "update", "patch"]
    api_groups = ["storage.k8s.io"]
    resources  = ["volumeattachments"]
  }
}

resource "kubernetes_cluster_role_binding" "vsphere_csi_controller_binding" {
  count = var.cloud_provider == "vsphere" ? 1 : 0
  metadata {
    name = "vsphere-csi-controller-binding"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "vsphere-csi-controller"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "vsphere-csi-controller-role"
  }
}

# https://github.com/kubernetes-sigs/vsphere-csi-driver/blob/9a23359530264ecf792f5a7badfbb32b2b01be40/manifests/v2.0.1/vsphere-67u3/vanilla/deploy/vsphere-csi-controller-deployment.yaml

resource "kubernetes_deployment" "vsphere_csi_controller" {
  count = var.cloud_provider == "vsphere" ? 1 : 0
  metadata {
    name      = "vsphere-csi-controller"
    namespace = "kube-system"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "vsphere-csi-controller"
      }
    }

    template {
      metadata {
        labels = {
          app = "vsphere-csi-controller"

          role = "vsphere-csi"
        }
      }

      spec {
        volume {
          name = "vsphere-config-volume"

          secret {
            secret_name = kubernetes_secret.csi_vsphere_creds.0.metadata.0.name
          }
        }

        volume {
          name = "socket-dir"

          host_path {
            path = "/var/lib/csi/sockets/pluginproxy/csi.vsphere.vmware.com"
            type = "DirectoryOrCreate"
          }
        }

        container {
          name  = "csi-attacher"
          image = "quay.io/k8scsi/csi-attacher:v2.0.0"
          args  = ["--v=4", "--timeout=300s", "--csi-address=$(ADDRESS)", "--leader-election"]

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
          name  = "vsphere-csi-controller"
          image = "gcr.io/cloud-provider-vsphere/csi/release/driver:v2.0.1"

          port {
            name           = "healthz"
            container_port = 9808
            protocol       = "TCP"
          }

          env {
            name  = "CSI_ENDPOINT"
            value = "unix:///var/lib/csi/sockets/pluginproxy/csi.sock"
          }

          env {
            name  = "X_CSI_MODE"
            value = "controller"
          }

          env {
            name  = "VSPHERE_CSI_CONFIG"
            value = "/etc/cloud/csi-vsphere.conf"
          }

          env {
            name  = "LOGGER_LEVEL"
            value = "PRODUCTION"
          }

          volume_mount {
            name       = "vsphere-config-volume"
            read_only  = true
            mount_path = "/etc/cloud"
          }

          volume_mount {
            name       = "socket-dir"
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
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

          lifecycle {
            pre_stop {
              exec {
                command = ["/bin/sh", "-c", "rm -rf /var/lib/csi/sockets/pluginproxy/csi.vsphere.vmware.com"]
              }
            }
          }

          image_pull_policy = "Always"
        }

        container {
          name  = "liveness-probe"
          image = "quay.io/k8scsi/livenessprobe:v1.1.0"
          args  = ["--csi-address=$(ADDRESS)"]

          env {
            name  = "ADDRESS"
            value = "/var/lib/csi/sockets/pluginproxy/csi.sock"
          }

          volume_mount {
            name       = "socket-dir"
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
          }
        }

        container {
          name  = "vsphere-syncer"
          image = "gcr.io/cloud-provider-vsphere/csi/release/syncer:v2.0.1"
          args  = ["--leader-election"]

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

          volume_mount {
            name       = "vsphere-config-volume"
            read_only  = true
            mount_path = "/etc/cloud"
          }

          image_pull_policy = "Always"
        }

        container {
          name  = "csi-provisioner"
          image = "quay.io/k8scsi/csi-provisioner:v2.0.0"
          args  = ["--v=4", "--timeout=300s", "--csi-address=$(ADDRESS)", "--leader-election"]

          env {
            name  = "ADDRESS"
            value = "/csi/csi.sock"
          }

          volume_mount {
            name       = "socket-dir"
            mount_path = "/csi"
          }
        }

        dns_policy                      = "Default"
        service_account_name            = "vsphere-csi-controller"
        automount_service_account_token = true

        toleration {
          operator = "Exists"
          effect   = "NoSchedule"
        }

        toleration {
          operator = "Exists"
          effect   = "NoExecute"
        }
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_unavailable = "1"
      }
    }
  }
}

resource "kubernetes_csi_driver" "csi_vsphere_vmware_com" {
  count = var.cloud_provider == "vsphere" ? 1 : 0
  metadata {
    name = "csi.vsphere.vmware.com"
  }

  spec {
    attach_required   = true
    pod_info_on_mount = false
  }
}

# https://github.com/kubernetes-sigs/vsphere-csi-driver/blob/9a23359530264ecf792f5a7badfbb32b2b01be40/manifests/v2.0.1/vsphere-67u3/vanilla/deploy/vsphere-csi-node-ds.yaml

resource "kubernetes_daemonset" "vsphere_csi_node" {
  count = var.cloud_provider == "vsphere" ? 1 : 0
  metadata {
    name      = "vsphere-csi-node"
    namespace = "kube-system"
  }

  spec {
    selector {
      match_labels = {
        app = "vsphere-csi-node"
      }
    }

    template {
      metadata {
        labels = {
          app = "vsphere-csi-node"

          role = "vsphere-csi"
        }
      }

      spec {
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

        container {
          name  = "node-driver-registrar"
          image = "quay.io/k8scsi/csi-node-driver-registrar:v1.2.0"
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

          lifecycle {
            pre_stop {
              exec {
                command = ["/bin/sh", "-c", "rm -rf /registration/csi.vsphere.vmware.com-reg.sock /csi/csi.sock"]
              }
            }
          }

          security_context {
            privileged = true
          }
        }

        container {
          name  = "vsphere-csi-node"
          image = "gcr.io/cloud-provider-vsphere/csi/release/driver:v2.0.1"

          port {
            name           = "healthz"
            container_port = 9808
            protocol       = "TCP"
          }

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
            name  = "X_CSI_DEBUG"
            value = "true"
          }

          env {
            name  = "LOGGER_LEVEL"
            value = "PRODUCTION"
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

          image_pull_policy = "Always"

          security_context {
            capabilities {
              add = ["SYS_ADMIN"]
            }

            privileged                 = true
            allow_privilege_escalation = true
          }
        }

        container {
          name  = "liveness-probe"
          image = "quay.io/k8scsi/livenessprobe:v1.1.0"
          args  = ["--csi-address=/csi/csi.sock"]

          volume_mount {
            name       = "plugin-dir"
            mount_path = "/csi"
          }
        }

        dns_policy = "Default"

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

    strategy {
      type = "RollingUpdate"
    }
  }
}