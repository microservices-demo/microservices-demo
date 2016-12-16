output "node_addresses" {
  value = ["${aws_instance.md-k8s-node.*.public_dns}"]
}

output "master_address" {
  value = "${aws_instance.md-k8s-master.public_dns}"
}

output "sock_shop_address" {
  value = "${aws_elb.elb-sock-shop.dns_name}"
}
