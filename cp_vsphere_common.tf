

# vSphere Cloud Controller Manager


resource "kubernetes_service_account" "vsphere_cloud_controller_manager" {
  count = local.install_cp_vsphere

  depends_on = [helm_release.calico, local_sensitive_file.kube_cluster_yaml]

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
  count = local.install_cp_vsphere

  depends_on = [helm_release.calico, local_sensitive_file.kube_cluster_yaml]
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
  count = local.install_cp_vsphere

  depends_on = [helm_release.calico, local_sensitive_file.kube_cluster_yaml]
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
  count = local.install_cp_vsphere

  depends_on = [helm_release.calico, local_sensitive_file.kube_cluster_yaml]
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
  count = local.install_cp_vsphere

  depends_on = [helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name = "system:cloud-controller-manager"
    labels = {
      # version 19 es cluster-role-binding
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
  count = local.install_cp_vsphere

  depends_on = [helm_release.calico, local_sensitive_file.kube_cluster_yaml]
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
  count = local.install_cp_vsphere

  depends_on = [helm_release.calico, local_sensitive_file.kube_cluster_yaml, null_resource.nodes_taint[0]]
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
        #ver por que esta comentada esta toleration en 1.24
        toleration {
          key      = "node.kubernetes.io/not-ready"
          operator = "Exists"
          effect   = "NoSchedule"
        }

        security_context {
          run_as_user = 1001
        }

        automount_service_account_token = true
        service_account_name            = kubernetes_service_account.vsphere_cloud_controller_manager.0.metadata.0.name

        #se agrego v.1.24 ? no existe manifiesto yaml
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

#######


resource "kubernetes_namespace" "vsphere_csi_namespace" {
  count = local.install_cp_vsphere

  depends_on = [helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name = "vmware-system-csi"
  }
  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_secret" "csi_vsphere_creds" {
  count = local.install_cp_vsphere

  depends_on = [helm_release.calico, local_sensitive_file.kube_cluster_yaml]
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
# https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/v2.6.2/manifests/vanilla/vsphere-csi-driver.yaml
resource "kubernetes_csi_driver_v1" "vsphere_csi_vmware_com" {
  count = local.install_cp_vsphere

  depends_on = [helm_release.calico, kubernetes_daemonset.vsphere_cloud_controller_manager[0], local_sensitive_file.kube_cluster_yaml]

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
  count = local.install_cp_vsphere

  depends_on = [helm_release.calico, local_sensitive_file.kube_cluster_yaml]
  metadata {
    name      = "vsphere-csi-controller"
    namespace = kubernetes_namespace.vsphere_csi_namespace.0.metadata.0.name
  }
  automount_service_account_token = true
}




resource "kubernetes_cluster_role_binding" "vsphere_csi_controller_binding" {

  count = local.install_cp_vsphere


  depends_on = [helm_release.calico, local_sensitive_file.kube_cluster_yaml]

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
  count = local.install_cp_vsphere

  depends_on = [helm_release.calico, local_sensitive_file.kube_cluster_yaml]

  metadata {
    name      = "vsphere-csi-node"
    namespace = kubernetes_namespace.vsphere_csi_namespace.0.metadata.0.name
  }
  automount_service_account_token = true
}

resource "kubernetes_cluster_role_binding" "vsphere_csi_node_cluster_role_binding" {
  count = local.install_cp_vsphere

  depends_on = [helm_release.calico, local_sensitive_file.kube_cluster_yaml]
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
    name      = kubernetes_cluster_role.vsphere_csi_node_cluster_role.0.metadata.0.name
  }
}


resource "kubernetes_role" "vsphere_csi_node" {
  count = local.install_cp_vsphere

  depends_on = [helm_release.calico, local_sensitive_file.kube_cluster_yaml]
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
  count = local.install_cp_vsphere

  depends_on = [helm_release.calico, local_sensitive_file.kube_cluster_yaml]
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


resource "kubernetes_service" "vsphere_cloud_controller_manager" {

  count      = local.install_cp_vsphere
  depends_on = [helm_release.calico, local_sensitive_file.kube_cluster_yaml]

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

    type = "NodePort" #tipo de servicio no especificado 
  }
  lifecycle {
    ignore_changes = [metadata]
  }
}




