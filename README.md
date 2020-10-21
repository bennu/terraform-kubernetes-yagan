# Yagan kubernetes

|Variable|Description|Required|Default|
|:---|---|:---:|:---|
|`addon_job_timeout`|Timeout for addons deployment in seconds||`120`|
|`addons_include`|URLs and/or local files to deploy withing RKE bootstrapping process||`[]`|
|`always_pull_images`|Enable [always pull images admission controler](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#alwayspullimages) in the api-server||`true`|
|`api_server_lb`|List of IPs on loadbalancer in front of kube-api-sever(s)||`[]`|
|`cgroup_driver`|Driver that the kubelet uses to manipulate cgroups on the host||`cgroupfs`|
|`cilium_allocate_bpf`|Pre-allocation of map entries allows per-packet latency to be reduced, at the expense of up-front memory allocation for the entries in the maps. Set to `true` to optimize for latency. If this value is modified, then during the next Cilium startup connectivity may be temporarily disrupted for endpoints with active connections||`true`|
|`cilium_debug`|Sets to run Cilium in full debug mode, which enables verbose logging and configures BPF programs to emit more visibility events into the output of `cilium monitor`||`true`|
|`cilium_ipam`|IPAM method to use for kubernetes cluster||`kubernetes`|
|`cilium_monitor`|This option enables coalescing of tracing events in `cilium monitor` to only include periodic updates from active flows, or any packets that involve an L4 connection state change. Valid options are `none`, `low`, `medium`, `maximum`||`maximum`|
|`cilium_node_init`|Initialize nodes for cilium||`true`|
|`cilium_node_init_restart_pods`|Restart pods not managed by cilium||`true`|
|`cilium_operator_prometheus_enabled`|Create service monitor for prometheus operator to use||`true`|
|`cilium_operator_replicas`|Replicas to create for cilium operator||`2`|
|`cilium_prometheus_enabled`|Add annotations to pods for prometheus to monitor||`true`|
|`cilium_psp_enabled`|Create PodSecurityPolicies for cilium pods||`true`|
|`cilium_require_ipv4_pod_cidr`|Requier Pod cidr to allocate pod IPs||`true`|
|`cilium_service_monitor_enabled`|Create service monitor for cilium||`kubernetes`|
|`cilium_tunnel`|Encapsulation tunnel to use||`vxlan`|
|`cilium_wait_bfp`|Wait for BPF to be present in order to work||`kubernetes`|
|`cluster_cidr`|Cluster CIDR for pods IP allocation||`10.42.0.0/16`|
|`cluster_domain`|Domain for cluster-wide service discovery||`cluster.local`|
|`delete_local_data_on_drain`|Delete local data on node drain||`true`|
|`dns_provider`|Cluster DNS service provider||`coredns`|
|`drain_grace_period`|Grace period to wait for node to drain||`-1`|
|`drain_on_upgrade`|Do drain operations on upgrades||`true`|
|`drain_timeout`|Time to wait for node to drain||`60`|
|`enforce_node_allocatable`|Enforce allocatable resources||`pods,system-reserved,kube-reserved`|
|`etcd_backup_interval_hours`|Interval hours for `etcd` backups||`8`|
|`etcd_backup_retention`|Amount of backups to keep in parallel||`6`|
|`etcd_extra_args`|A map of extra args for `etcd`||`{ election-timeout = "5000", heartbeat-interval = "500" }`|
|`etcd_extra_binds`|A list of host volumes to bind to `etcd`||`[]`|
|`etcd_extra_env`|A list of env vars to prepend to `etcd`||`[]`|
|`etcd_s3_access_key`|S3 account access key for storing `etcd` backups|||
|`etcd_s3_bucket_name`|S3 bucket for storing `etcd` backups|||
|`etcd_s3_endpoint`|Endpoint for S3 and S3 compatible services for storing `etcd` backups|||
|`etcd_s3_folder`|S3 folder for storing `etcd` backups|||
|`etcd_s3_region`|S3 region for storing `etcd` backups|||
|`etcd_s3_secret_key`|S3 account secret for storing `etcd` backups|||
|`eviction_hard`|Params for eviction||`memory.available<15%,nodefs.available<10%,nodefs.inodesFree<5%,imagefs.available<15%,imagefs.inodesFree<20%`|
|`fail_swap_on`|Do not allow to deploy kubernetes on systems with swap partitions enabled||`true`|
|`force_drain`|Force drain on upgrades||`true`|
|`generate_serving_certificate`|Generate serving certificate||`true`|
|`hubble_enabled`|Enable hubble||`true`|
|`hubble_metrics`|Metrics to be fetched by hubble||`{dns,drop,tcp,flow,port-distribution,icmp,http}`|
|`hubble_relay_enabled`|Enable hubble releay|`true`|
|`hubble_ui_enabled`|Enable hubble UI||`true`|
|`ignore_daemon_sets_on_drain`|Drain despite of daemonset||`true`|
|`ignore_docker_version`|Do not check `docker` version when deploying RKE||`true`|
|`ingress_provider`|Deploy RKE built-in ingress controller||`none`|
|`kube_api_extra_args`|A map of extra args for `api-server`||`{ feature-gates = "APIResponseCompression=true" }`|
|`kube_api_extra_binds`|A list of host volumes to bind to `api-server`||`[]`|
|`kube_api_extra_env`|A list of env vars to prepend to `api-server`||`[]`|
|`kube_controller_extra_args`|A map of extra args for `controller`||`{}`|
|`kube_controller_extra_binds`|A list of host volumes to bind to `controller`||`[]`|
|`kube_controller_extra_env`|A list of env vars to prepend to `controller`||`[]`|
|`kube_reserved_cgroup`|Cgroup for kubernetes pods||`/podruntime.slice`|
|`kube_reserved`|Resources reserved for kubernetes pods||`cpu=300m,memory=500Mi`|
|`kubelet_extra_args`|A map of extra args for `kubelet`||`{ max-pods = 30 }`|
|`kubelet_extra_binds`|A list of host volumes to bind to `kubelet`||`[]`|
|`kubelet_extra_env`|A list of env vars to prepend to `kubelet`||`[]`|
|`kubeproxy_extra_args`|A map of extra args for `kube-proxy`||`{}`|
|`kubeproxy_extra_binds`|A list of host volumes to bind to `kube-proxy`||`[]`|
|`kubeproxy_extra_env`|A list of env vars to prepend to `kube-proxy`||`[]`|
|`kubernetes_version`|RKE version to deploy||*latest available*|
|`max_pods`|Max ammount of pods to deploy per node||`32`|
|`monitoring`|Monitoring service for kubernetes||`metrics-server`|
|`node_cidr_mask_size`|Mask size to assign to each node based on `cluster_cidr`||`26`|
|`node_monitor_grace_period`|Grace period for node monitoring||`15s`|
|`node_monitor_period`|Period time for node monitoring||`2s`|
|`node_status_update_frequency`|Frequency to report node status to api-server||`4s`|
|`node_user`|Default user to connect to nodes as||`kubernetes`|
|`nodes`|A map of objects containing a list of node names and a IPs for each type (See: [yagan examples](https://github.com/bennu/yagan/tree/master/examples))|X||
|`pod_security_policy`|Deploy a permissive default set of PSP||`false`|
|`private_key`|Private ssh key for nodes|X||
|`resource_naming`|An arbitrary name can be prepend to resources. If not set, a random prefix will be created instead|||
|`rke_authorization`|RKE authorization mode||`rbac`|
|`sans`|An alternative subject alternate name (SAN) list for `api-server` tls certs||`[]`|
|`scheduler_extra_args`|A map of extra args for `scheduler`||`{}`|
|`scheduler_extra_binds`|A list of host volumes to bind to `scheduler`||`[]`|
|`scheduler_extra_env`|A list of env vars to prepend to `scheduler`||`[]`|
|`service_cluster_ip_range`|CIDR for services allocation||`10.43.0.0/16`|
|`service_node_port_range`|Range for nodeport allocation||`30000-32767`|
|`system_reserved_cgroup`|Cgroup for system tasks|`/system.slice`|
|`system_reserved`|Resources reserved for system tasks||`cpu=700m,memory=1Gi`|
|`upgrade_max_unavailable_controlplane`|Max ammount of controlplane nodes that can be unavailable during upgrades||`1`|
|`upgrade_max_unavailable_worker`|Max ammount of worker nodes that can be unavailable during upgrades||`10%`|
|`write_kubeconfig`|Save kubeconfig to a file||`true`|
