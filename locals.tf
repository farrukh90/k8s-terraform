locals {
  worker_list = [for i in range(var.num_of_workers) : format("%s-%d", "worker", i+1)]

  k8s_vms = var.gvisor == "N" ? toset(concat(["master"], local.worker_list)) : (
    toset(concat(["master"], ["gvisor"], local.worker_list))
  )

  cni_provider =  var.cni_provider == "weavenet" ? (
      "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')") : (
      "https://docs.projectcalico.org/manifests/calico.yaml" )

  cluster_and_nw_install_script = templatefile("${path.module}/scripts/cluster_and_nw_install.sh", 
      { pod_cidr = var.pod_cidr, 
        service_cidr = var.service_cidr, 
        version = var.k8s_version,
        cni_provider = local.cni_provider})

  base_install_script = templatefile("${path.module}/scripts/base_install_script.sh", 
    { version = var.k8s_version })   

  gvisor_install_script = templatefile("${path.module}/scripts/gvisor_install.sh",
    { version = var.k8s_version })

  gcp_zone = join("-", [var.gcp_region, "a"])
}