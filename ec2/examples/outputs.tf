# ec2 example outputs

output "instance_ids" {
   value = module.my_ec2.instance_ids
}
output "sg_id" {
  value       = module.my_sg.sg_id
}