module "kubernetes-anywhere-aws-ec2" {
    source         = "github.com/weaveworks/weave-kubernetes-anywhere/phase1/aws-ec2-terraform"
    cluster	   = "${var.cluster}"
    ec2_key_name   = "${var.ec2_key_name}"
    aws_access_key = "${var.aws_access_key}"
    aws_secret_key = "${var.aws_secret_key}"
    aws_region     = "${var.aws_region}"
}
