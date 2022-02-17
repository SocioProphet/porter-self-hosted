variable "aws_region" {
    description = "The AWS region to provision the VPC in."

    type    = string

    default = "us-east-1"
}

variable "aws_profile" {
    description = "The name of the local AWS profile to use."

    type    = string

    default = "porter"
}

variable "env_name" {
    description = "The name of the environment, like staging or production. Resources will inherit this prefix."

    type    = string

    default = "porter"
}

variable "private_subnets" {
    description = "Sets the private subnet CIDRs."

    type = list(string)

    default = ["10.99.1.0/24", "10.99.2.0/24", "10.99.3.0/24"]
}

variable "public_subnets" {
    description = "Sets the public subnet CIDRs."

    type = list(string)

    default = ["10.99.4.0/24", "10.99.5.0/24", "10.99.6.0/24"]
}

variable "database_subnets" {
    description = "Sets the database subnet CIDRs."

    type = list(string)

    default = ["10.99.7.0/24", "10.99.8.0/24", "10.99.9.0/24"]
}

variable "database_subnets_enabled" {
    description = "Sets whether database subnets should be enabled"

    type = bool

    default = true
}