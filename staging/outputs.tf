output "node_addresses" {
  value = ["${aws_instance.k8s-node.*.public_ip}"]
}

output "master_address" {
  value = "${aws_instance.k8s-master.public_ip}"
}
