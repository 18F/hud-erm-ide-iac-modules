# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/hs-cluster-alb outputs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Launch configuration
output "this_launch_configuration_id" {
  description = "The ID of the launch configuration"
  value       = module.autoscaling.this_launch_configuration_id
}

# Autoscaling group
output "this_autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = module.autoscaling.this_autoscaling_group_id
}

# ELB DNS name
output "lb_dns_name" {
  description = "DNS Name of the ALB"
  value       = aws_lb.my_lb.dns_name
}