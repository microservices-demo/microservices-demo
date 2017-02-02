output "node_addresses" {
  value = ["${aws_instance.ci-sockshop-docker-swarm-node.*.public_ip}"]
}

output "master_address" {
  value = "${aws_instance.ci-sockshop-docker-swarm-master.public_ip}"
}
