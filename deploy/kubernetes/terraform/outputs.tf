output "node_addresses" {
  value = ["${aws_instance.MD-k8s-node.*.public_dns}"]
}

output "master_address" {
  value = "${aws_instance.MD-k8s-master.public_dns}"
}

output "sock_shop_address" {
  value = "${aws_elb.elb-sock-shop.dns_name}"
}

output "scope_address" {
  value = "${aws_elb.elb-scope.dns_name}"
}
