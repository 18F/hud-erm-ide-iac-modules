# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# outputs for module ide-ec2
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

output "web_sg_id" {
  value = aws_security_group.allow_http_ssh.id
}

output "trainer_id" {
  value = aws_instance.instance
}
output "instance_ids" {
   value = [ for a in aws_instance.instance: a.id ]
}

output "all_instance_data" {
  value = aws_instance.instance
}
