# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# varialbles for module ide-ec2
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

variable "instance_data" {
  description = "data map with details of each instance to loop over"
  type = map
  default = {
      "ec2-01" = {
        ami           = "ami-532f1632", # Ubuntu Server 18.04 LTS (HVM), SSD Volume Type - ami-532f1632
        instance_type = "t3.2xlarge",   # 8 vcpu 32gb Ram
        subnet_id     = ""
      }
  }
}
variable "name_prefix" {}
variable "key_name" {}
variable "vpc_id" {}


# variable "ami" {}
# variable "instance_type" {}
# variable "subnet_id" {}

variable "iam_instance_profile" {
  description = "iam instance profile name"
  default     = ""
}
variable "root_block_device_size" {
  default = "50"
}

variable "cidr_blocks_ingress_ssh" {
  type        = list(string)
  description = "ssh ingress from mgmt hosts"
  default     = ["10.20.1.77/32"]
}




