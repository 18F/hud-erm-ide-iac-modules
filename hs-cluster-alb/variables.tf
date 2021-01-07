# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/hs-cluster-alb variables
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# autoscaling hs
variable "name_prefix" {}
variable "image_id" {} # ami
variable "instance_type" {}
variable "key_name" {}
variable "iam_instance_profile" {}
variable "private_subnet_ids" { type = list(string) }

variable "min_size" { default = 1 }
variable "max_size" { default = 2 }
variable "desired_capacity" { default = 1 }
variable "user_data" {}

# hs trainer
variable "trainer_image_id" {} 
variable "trainer_instance_type" {}
variable "trainer_user_data" {}

# load balancer
variable "public_subnet_ids" { type = list(string) }
variable "certificate_arn" {}

# security groups
variable "vpc_id" {}
variable "cidr_blocks_ingress_http" { type = list(string) }
variable "cidr_blocks_ingress_ssh" { type = list(string) }


