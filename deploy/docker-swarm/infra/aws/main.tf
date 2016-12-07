provider "aws" {
  region = "${var.region}"
}

data "aws_ami" "docker-swarm" {
  most_recent = true
  filter {
    name = "name"
    values = ["docker-swarm"]
  }
}

resource "aws_security_group" "docker-swarm" {
  name        = "docker-swarm"
  description = "allow all internal traffic, all traffic http from anywhere"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = "true"
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 30000
    to_port     = 30000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22 
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 2377
    to_port     = 2377 
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 7946 
    to_port     = 7946 
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 4789 
    to_port     = 4789 
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

resource "aws_instance" "docker-swarm-node" {
  depends_on      = [ "aws_instance.docker-swarm-master" ] 
  count           = "${var.num_nodes}"
  instance_type   = "${var.instance_type}"
  ami             = "${data.aws_ami.docker-swarm.id}"
  key_name        = "${var.private_key_name}"
  security_groups = ["${aws_security_group.docker-swarm.name}"]
  tags {
    Name = "docker-swarm-node"
  }

  connection {
    user = "ubuntu"
    private_key = "${file("${var.private_key_path}")}"
  }

  provisioner "file" {
    source = "join.sh",
    destination = "/tmp/join.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "sudo service docker start",
        "chmod +x /tmp/join.sh",
        "/tmp/join.sh"
    ]
  }
}

resource "aws_instance" "docker-swarm-master" {
  instance_type   = "${var.instance_type}"
  ami             = "${data.aws_ami.docker-swarm.id}"
  key_name        = "${var.private_key_name}"
  security_groups = ["${aws_security_group.docker-swarm.name}"]
  tags {
    Name = "docker-swarm-master"
  }

  connection {
    user = "ubuntu"
    private_key = "${file("${var.private_key_path}")}"
  }

  provisioner "file" {
     source = "deploy/docker-swarm/docker-compose.yml"
     destination = "/tmp/docker-compose.yml"
  }

  provisioner "remote-exec" {
    inline = [
        "sudo service docker start",
        "docker swarm init",
    ]
  }

  provisioner "local-exec" {
    command = "TOKEN=$(ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ubuntu@${aws_instance.docker-swarm-master.public_ip} docker swarm join-token -q worker); echo \"#!/usr/bin/env bash\ndocker swarm join --token $TOKEN ${aws_instance.docker-swarm-master.public_ip}:2377\" >| join.sh"
  }
}

resource "null_resource" "docker-swarm" {
  depends_on = [ "aws_instance.docker-swarm-node" ] 
  connection {
    user = "ubuntu"
    private_key = "${file("${var.private_key_path}")}"
    host = "${aws_instance.docker-swarm-master.public_ip}"
  }
  provisioner "remote-exec" {
    inline = [
        "docker-compose -f /tmp/docker-compose.yml pull",
        "docker-compose -f /tmp/docker-compose.yml bundle -o dockerswarm.dab",
        "docker deploy dockerswarm"
    ]
  }

  provisioner "local-exec" {
    command = "rm join.sh"
  }
}
