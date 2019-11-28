output "ips" {
  value = google_compute_instance.rke.*.network_interface.0.access_config.0.nat_ip
}

output "nginx_url" {
  value = "http://${google_compute_instance.rke[0].network_interface.0.access_config.0.nat_ip}:30080"
}