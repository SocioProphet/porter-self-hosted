variable "aws_region" {
    description = "The AWS region to provision the VPC in."

    type    = string

    default = "us-east-2"
}

variable "aws_profile" {
    description = "The name of the local AWS profile to use."

    type    = string

    default = "default"
}

variable "vpc_id" {
    description = "The ID of the VPC to provision the cluster in."

    type = string
}

variable "vpc_cidr_block" {
    description = "The CIDR block of the VPC."

    type = string
}

variable "database_subnets" {
    description = "The IDs of the database subnets to use for the RDS configuration."

    type = list(string)
}

variable "env_name" {
    description = "The name of the environment, like staging or production. Resources will inherit this prefix."

    type    = string

    default = "porter"
}