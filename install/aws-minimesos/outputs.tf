output "# SSH key" {
  value = "\nexport KEY=${var.private_key_file}"
}

output "# instance" {
  value = "\nexport IP=${aws_instance.minimesos.public_dns}"
}
