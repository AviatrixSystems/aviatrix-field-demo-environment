output "controller_instance_id" {
  value = aws_cloudformation_stack.avx_ctrl_cplt.outputs.AviatrixControllerInstanceID
}

output "controller_public_ip" {
  value = aws_cloudformation_stack.avx_ctrl_cplt.outputs.AviatrixControllerEIP
}

output "controller_private_ip" {
  value = aws_cloudformation_stack.avx_ctrl_cplt.outputs.AviatrixControllerPrivateIP
}

output "controller_vpc_id" {
  value = aws_cloudformation_stack.avx_ctrl_cplt.outputs.AviatrixVpcID
}

output "controller_subnet_id" {
  value = aws_cloudformation_stack.avx_ctrl_cplt.outputs.AviatrixSubnetID
}

output "controller_security_group_id" {
  value = aws_cloudformation_stack.avx_ctrl_cplt.outputs.AviatrixControllerSecurityGroupID
}

output "copilot_instance_id" {
  value = aws_cloudformation_stack.avx_ctrl_cplt.outputs.AviatrixCoPilotInstanceID
}

output "copilot_public_ip" {
  value = aws_cloudformation_stack.avx_ctrl_cplt.outputs.AviatrixCoPilotEIP
}

output "copilot_private_ip" {
  value = aws_cloudformation_stack.avx_ctrl_cplt.outputs.AviatrixCoPilotPrivateIP
}

output "aws_account" {
  value = data.aws_caller_identity.aws_account.account_id
}
