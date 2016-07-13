module "kubernetes-anywhere-aws-ec2" {
    source         = "github.com/weaveworks/weave-kubernetes-anywhere/phase1/aws-ec2-terraform"
    aws_access_key = "{AWS_KEY}"
    aws_secret_key = "{AWS_SECRET}"
    aws_region     = "eu-west-1"
    cluster        = "weave1"

    # You can also set instance types with node_instance_type/master_instance_type/etcd_instance_type
    # For SSH access, you will need to create a key named kubernetes-anywhere or set ec2_key_name

}
