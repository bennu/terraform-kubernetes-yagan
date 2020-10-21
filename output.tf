output api_server_url { value = local.api_access }
output ca_crt { value = rke_cluster.cluster.ca_crt }
output client_cert { value = rke_cluster.cluster.client_cert }
output client_key { value = rke_cluster.cluster.client_key }
output cluster { value = rke_cluster.cluster }
output cluster_name { value = rke_cluster.cluster.cluster_name }
output kube_admin_user { value = rke_cluster.cluster.kube_admin_user }
output kubeconfig { value = local_file.kube_cluster_yaml }
