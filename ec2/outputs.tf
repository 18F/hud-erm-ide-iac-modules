# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# outputs for module/ec2
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


output "instance_ids" {
   value = [ for a in aws_instance.instance: a.id ]
}

output "all_instance_data" {
  value = aws_instance.instance
}