output "node_addresses" {
  value = ["${google_compute_instance.docker-swarm-node.*.network_interface.0.access_config.0.assigned_nat_ip}"]
}

output "master_address" {
  value = "${google_compute_instance.docker-swarm-master.network_interface.0.access_config.0.assigned_nat_ip}"
}
