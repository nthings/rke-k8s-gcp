resource "rancher2_cluster" "gcp-cluster" {
  name = "gcp-demo"
}

resource "null_resource" "rke" {
  provisioner "local-exec" {
    command = "echo \"${templatefile("templates/rke.tmpl", {
      ips              = google_compute_instance.rke.*.network_interface.0.access_config.0.nat_ip,
      private_ips      = google_compute_instance.rke.*.network_interface.0.network_ip,
      user             = var.ssh_user,
      private_key_path = var.ssh_private_key
    })}\" > cluster.yml"
  }

  provisioner "local-exec" {
    command = <<EOT
rke up --config cluster.yml;
export KUBECONFIG=kube_config_cluster.yml;
${rancher2_cluster.gcp-cluster.cluster_registration_token.0.command};
kubectl apply -f ./nginx.yml;
xdg-open http://${google_compute_instance.rke[0].network_interface.0.access_config.0.nat_ip}:30080;
    EOT
  }

  depends_on = ["google_compute_instance.rke"]
}

resource "null_resource" "remove_files" {
  provisioner "local-exec" {
    command = <<EOT
rm -f kube_config_cluster.yml;
rm -f cluster.yml;
rm -f cluster.rkestate;
    EOT
    when    = "destroy"
  }
}