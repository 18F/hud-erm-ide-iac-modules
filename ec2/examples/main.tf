# ec2 examples

#################
# ec2 module test
#################
module "my_ec2" {
  source = "../../../modules/ec2"

  instance_data = {
    "${var.name_prefix}-ec2-01" = {
      ami           = "ami-532f1632", # Ubuntu Server 18.04 LTS (HVM), SSD Volume Type - ami-532f1632
      instance_type = "c5.4xlarge",   # 16 vcpu 32gb Ram
      subnet_id     = local.private_subnet_ids[0]
    },
    "${var.name_prefix}-ec2-02" = {
      ami           = "ami-532f1632", # Ubuntu Server 18.04 LTS (HVM), SSD Volume Type - ami-532f1632
      instance_type = "c5.4xlarge",   # 16 vcpu 32gb Ram
      subnet_id     = local.private_subnet_ids[1]
    }
  }
  

  key_name                = var.key_name
  vpc_security_group_ids      = [module.my_sg.sg_id]
  iam_instance_profile    = local.aws_iam_s3_instance_profile 
  root_block_device_size = "100" 
}