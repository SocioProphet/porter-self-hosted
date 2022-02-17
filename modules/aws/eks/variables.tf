variable "aws_region" {
  description = "The AWS region to provision the VPC in."

  type = string

  default = "us-east-1"
}

variable "aws_profile" {
  description = "The name of the local AWS profile to use."

  type = string

  default = "porter"
}

variable "vpc_id" {
  description = "The ID of the VPC to provision the cluster in."

  type = string
}

variable "private_subnets" {
  description = "The IDs of the private subnets to use for the EKS cluster configuration."

  type = list(string)
}

variable "env_name" {
  description = "The name of the environment, like staging or production. Resources will inherit this prefix."

  type = string

  default = "porter"
}

variable "machine_type" {
  description = "The machine type to use for autoscaling nodes in the EKS cluster."

  type = string

  default = "t2.medium"
}

variable "support_email" {
  description = "The support email to use for certificate expiry"

  type = string
}

variable "max_instances" {
  description = "The max number of instances for the default autoscaling group"

  type = number

  default = 10
}
