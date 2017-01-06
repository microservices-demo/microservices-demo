provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_security_group" "microservices-demo-staging-k8s" {
  name        = "microservices-demo-staging-k8s"
  description = "allow all internal traffic, all traffic from bastion and http from anywhere"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = "true"
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.bastion_cidr_block}"]
  }
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${var.bastion_security_group}"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "k8s-node" {
  depends_on      = [ "aws_instance.k8s-master" ] 
  count           = "${var.nodecount}"
  instance_type   = "${var.node_instance_type}"
  ami             = "${lookup(var.aws_amis, var.aws_region)}"
  key_name        = "${var.key_name}"
  security_groups = ["${aws_security_group.microservices-demo-staging-k8s.name}"]
  tags {
    Name = "microservices-demo-staging-node"
  }

  root_block_device {
    volume_type = "gp2"
    volume_size = "32"
  }

  connection {
    user        = "${var.instance_user}"
    private_key = "${file("${var.private_key_file}")}"
  }

  provisioner "file" {
    source      = "install_kubeadm.sh"
    destination = "/tmp/install_kubeadm.sh"
  }
 
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_kubeadm.sh", 
      "/tmp/install_kubeadm.sh"
    ]
  }

  provisioner "local-exec" {
    command = "sh join_node.sh ${self.private_ip}"
  }
}

resource "aws_instance" "k8s-master" {
  instance_type   = "${var.master_instance_type}"
  ami             = "${lookup(var.aws_amis, var.aws_region)}"
  key_name        = "${var.key_name}"
  security_groups = ["${aws_security_group.microservices-demo-staging-k8s.name}"]
  tags {
    Name = "microservices-demo-staging-master"
  }

  root_block_device {
    volume_type = "gp2"
    volume_size = "32"
  }

  provisioner "remote-exec" {
    connection {
      user        = "${var.instance_user}"
      private_key = "${file("${var.private_key_file}")}"
    }
    scripts = [ 
      "install_kubeadm.sh"
    ]
  }

  provisioner "local-exec" {
    command = "sh init_master.sh ${self.public_ip}"
  }
}

resource "null_resource" "weave-kube" {
  depends_on = [ "aws_instance.k8s-node" ]
  provisioner "local-exec" {
    command = "kubectl apply -f https://git.io/weave-kube"
  }
}

resource "null_resource" "weave-flux" {
  depends_on = [ "aws_instance.k8s-node" ]
  provisioner "local-exec" {
    command = <<EOT
        kubectl apply -f https://raw.githubusercontent.com/weaveworks/flux/master/deploy/standalone/flux-deployment.yaml;
        kubectl apply -f https://raw.githubusercontent.com/weaveworks/flux/master/deploy/standalone/flux-service.yaml
    EOT
  }
}

resource "aws_elb" "microservices-demo-staging-k8s" {
  depends_on = [ "aws_instance.k8s-node" ]
  name = "microservices-demo-staging-k8s"
  instances = ["${aws_instance.k8s-node.*.id}"]
  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  security_groups = ["${aws_security_group.microservices-demo-staging-k8s.id}"]

  listener {
    lb_port = 80
    instance_port = 30000
    lb_protocol = "http"
    instance_protocol = "http"
  }
}

resource "aws_elb" "microservicesdemo-staging-scope" {
  depends_on = [ "aws_instance.k8s-node" ]
  name = "microservicesdemo-staging-scope"
  instances = ["${aws_instance.k8s-node.*.id}"]
  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  security_groups = ["${aws_security_group.microservices-demo-staging-k8s.id}"]

  listener {
    lb_port = 80
    instance_port = 30001
    lb_protocol = "http"
    instance_protocol = "http"
  }
}
