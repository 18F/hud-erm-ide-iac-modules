# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# module/formio-s3 outputs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

output "s3_arn" {
  value = module.s3_bucket.this_s3_bucket_arn
}

output "aws_iam_s3_instance_profile" {
  value = aws_iam_instance_profile.test_profile.name
}

# output "s3_user" {
#   value = aws_iam_access_key.access_key.user
# }

# output "s3_user_key" {
#   value = aws_iam_access_key.access_key.id
# }

# output "s3_user_secret" {
#   value = aws_iam_access_key.access_key.secret
# }

# output "s3_policy_name" {
#   value = aws_iam_policy.policy.id
# }

# output "s3_bucket_name" {
#   value = aws_s3_bucket.bucket.id
# }