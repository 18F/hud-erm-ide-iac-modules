# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/hs-cluster-alb
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
terraform {
  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
  # The latest version of Terragrunt (v0.25.1 and above) recommends Terraform 0.13.3 or above.
  required_version = ">= 0.13.3"

  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.5.0"
    }
  }
}

###########################
# application load balancer
###########################
resource "aws_lb" "my_lb" {
  name     = "${var.name_prefix}-lb"
  internal = false

  security_groups = [aws_security_group.lb.id, ]

  subnets = var.public_subnet_ids

  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  tags = {
    Name = "${var.name_prefix}-lb"
  }
}
###########################
# listeners
###########################
resource "aws_lb_listener" "lb_listener_http" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = 80
  protocol          = "HTTP"

  # default_action {
  #   type             = "forward"
  #   target_group_arn = aws_lb_target_group.my_tg.arn
  # }
  default_action {
    type             = "redirect"
    target_group_arn = aws_lb_target_group.my_tg.arn
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
resource "aws_lb_listener" "lb_listener_https" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_tg.arn
  }
}

##############
# target group
##############
resource "aws_lb_target_group" "my_tg" {
  health_check {
    interval            = 10
    path                = "/login"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name        = "${var.name_prefix}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
}

###################################################
# Launch configuration and autoscaling group for hs
###################################################
module "autoscaling" {
  source = "terraform-aws-modules/autoscaling/aws"
  # version = "3.8.0"

  name = "${var.name_prefix}"

  # Launch configuration
  #
  # launch_configuration = "my-existing-launch-configuration" # Use the existing launch configuration
  # create_lc = false # disables creation of launch configuration
  lc_name = "${var.name_prefix}-lc"

  image_id             = var.image_id
  instance_type        = var.instance_type
  key_name             = var.key_name
  iam_instance_profile = var.iam_instance_profile

  security_groups = [aws_security_group.hs.id]
  # load_balancers  = [module.elb.this_elb_id]

  target_group_arns = ["${aws_lb_target_group.my_tg.arn}"]

  root_block_device = [
    {
      volume_size = "100"
      volume_type = "gp2"
    },
  ]

  user_data = var.user_data

  # Auto scaling group
  asg_name                  = "${var.name_prefix}-asg"
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_type         = "EC2"
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  wait_for_capacity_timeout = 0


  tags = [
    {
      key                 = "Environment"
      value               = "sandb2"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "ermide"
      propagate_at_launch = true
    },
  ]
}

###############
# hs trainer
###############
module "trainer" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.16.0"
  instance_count = 1

  name           = "${var.name_prefix}-trainer"
  ami           = var.trainer_image_id
  instance_type = var.trainer_instance_type

  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.hs.id]
  key_name               = var.key_name
  monitoring             = true
  user_data = var.trainer_user_data

  root_block_device = [
    {
      volume_size = 100
      volume_type = "gp2"
    },
  ]
  tags = {
    "Name" = "${var.name_prefix}-trainer"
  }
}
##############################
# security group for hs
##############################
resource "aws_security_group" "hs" {
  name        = "${var.name_prefix}-hs-cluster-sg"
  description = "Allow HTTP and ssh inbound connections"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = var.cidr_blocks_ingress_http
    security_groups = [aws_security_group.lb.id]
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
    Name = "${var.name_prefix}-hs-sg"
  }
}

##############################
# security group for lb
##############################
resource "aws_security_group" "lb" {
  name        = "${var.name_prefix}-hs-lb-sg"
  description = "Allow HTTP, HTTPS and SSH inbound connections"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "${var.name_prefix}-hs-sg"
  }
}