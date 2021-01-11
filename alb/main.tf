# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module-lb
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

##########################
# target group attachments
##########################
resource "aws_lb_target_group_attachment" "my_tg_attachment" {
  for_each = toset(var.instance_ids)

  target_group_arn = aws_lb_target_group.my_tg.arn
  target_id        = each.value
  port             = 80
}

###########################
# application load balancer
###########################
resource "aws_lb" "my_lb" {
  name     = "${var.name_prefix}-lb"
  internal = false

  security_groups = [ aws_security_group.my-lb-sg.id, ]

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
  certificate_arn = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_tg.arn
  }
}
###########################
# lb security group
###########################
resource "aws_security_group" "my-lb-sg" {
  name   = "${var.name_prefix}-lb-sg"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "inbound_ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.my-lb-sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "inbound_http" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.my-lb-sg.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "inbound_https" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.my-lb-sg.id
  to_port           = 443
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_all" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.my-lb-sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}