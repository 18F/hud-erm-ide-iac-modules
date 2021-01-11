# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/ide-ec2 - specific to IDE Cluster
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

##############################
# security group for ec2
##############################
resource "aws_security_group" "allow_http_ssh" {
  name        = "${var.name_prefix}-ec2-sg"
  description = "Allow HTTP and ssh inbound connections"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks_ingress_ssh
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-ec2-sg"
  }
}

##############
# ec2 with for_each
##############

resource "aws_instance" "instance" {
  for_each = var.instance_data

  ami           = each.value["ami"]
  instance_type = each.value.instance_type
  subnet_id     = each.value.subnet_id

  key_name             = var.key_name
  vpc_security_group_ids      = [aws_security_group.allow_http_ssh.id]
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
    Name = "${each.key}-ec2"
  }
}

