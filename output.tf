output api_server_url {
  description = "Kubernetes api-server endpoint"
  value       = local.api_access
}
output ca_crt {
  description = "Kubernetes CA certificate"
  value       = rke_cluster.cluster.ca_crt
}
output client_cert {
  description = "Kubernetes client certificate"
  value       = rke_cluster.cluster.client_cert
}
output client_key {
  description = "Kubernetes client key"
  value       = rke_cluster.cluster.client_key
}
output cluster {
  description = "Kubernetes cluster object"
  value       = rke_cluster.cluster
}
output cluster_name {
  description = "Kubernetes cluster name"
  value       = rke_cluster.cluster.cluster_name
}
output kube_admin_user {
  description = "Kubernetes admin user"
  value       = rke_cluster.cluster.kube_admin_user
}
output kubeconfig {
  description = "Kubernetes admin kubeconfig"
  value       = local_file.kube_cluster_yaml
}
