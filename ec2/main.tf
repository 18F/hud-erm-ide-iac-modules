# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/ec2
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

##############
# ec2 with for_each
##############

resource "aws_instance" "instance" {
  for_each = var.instance_data

  ami           = each.value["ami"]
  instance_type = each.value.instance_type
  subnet_id     = each.value.subnet_id

  key_name             = var.key_name
  vpc_security_group_ids      = var.vpc_security_group_ids
  iam_instance_profile = var.iam_instance_profile

  root_block_device {
    volume_size = var.root_block_device_size
    volume_type = "gp2"
  }

  user_data = <<-EOF
        #!/bin/bash
        echo "Hello, World" $HOSTNAME > index.html
        nohup busybox httpd -f -p 80 &
        EOF

  tags = {
    Name = "${each.key}"
  }
}