// This script expects the aws key and secret as variables. This is necessary because we need access to the aws varialbes during the provisioning step.
// e.g. terraform apply -var 'access_key=......' -var 'secret_key=......' .

// So, first run 'terraform get'
// Finally, run the plan and apply steps to create the cluster. You can also provide the aws credentials with environmental variables like: TF_VAR_access_keys...

resource "aws_instance" "microservices-test" {

  count = 1
  ami   = "${lookup(var.aws_amis, var.aws_region)}"
  availability_zone = "eu-west-1b"

  root_block_device {
    volume_size = 50
  }

  instance_type = "t2.large"
  key_name      = "${var.aws_key_name}"
  subnet_id     = "${aws_subnet.terraform.id}"

  vpc_security_group_ids = ["${aws_security_group.terraform.id}"]

  tags { Name = "mesos-master-${count.index}" }

  connection {
    user     = "ubuntu"
    key_file = "${var.private_key_file}"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 1; done"
    ]
  }

  provisioner "file" {
        source = "provision.sh"
        destination = "/tmp/provision.sh"
    }

    provisioner "remote-exec" {
        inline = [
          "chmod +x /tmp/provision.sh",
          "/tmp/provision.sh"
        ]
    }
}

output "# SSH key" { value = "\nexport KEY=${var.private_key_file}" }
output "# Instance" { value = "\nexport INSTANCE=${aws_instance.microservices-test.public_dns}" }
output "ZDummy" { value = "\nDummy" }
