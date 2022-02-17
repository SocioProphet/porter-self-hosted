# Porter On-Prem

This repository contains templates and instructions for self-hosting Porter.

## EKS + Terraform

Prerequisite: create a `.infra` folder via `mkdir .infra`.

### Step 1: Create the VPC

Inside the `.infra` folder, create a directory called `vpc`. In this directoy, add the following `main.tf` file:

```hcl
module "vpc" {
  source = "../../modules/aws/vpc"

  aws_region = "us-east-2" # TODO: your AWS region
  aws_profile = "default" # TODO: your AWS profile, if not default
  database_subnets_enabled = false # TODO: if using RDS, enable this
  env_name = "production" # TODO: the name of your environment
}
```

Then, run `terraform init` and `terraform apply`.

### Step 2: Create the EKS cluster

Inside the `.infra` folder, create a directory called `eks`. In this directoy, add the following `main.tf` file:

```hcl
module "eks" {
  source = "../../../modules/eks"

  aws_region = "us-east-2" # TODO: your AWS region
  aws_profile = "default" # TODO: your AWS profile, if not default
  env_name = "production" # TODO: the name of your environment
  vpc_id = "" # TODO: the VPC ID, output from the step above
  private_subnets = [] # TODO: fill these out with the subnet IDs from above

  support_email = "contact@porter.run" # TODO: support email for certificate updates
}
```

Then, run `terraform init` and `terraform apply`. Next, generate a kubeconfig for your cluster via `aws eks update-kubeconfig --region <YOUR-REGION> --name <ENV-NAME>`.

### Step 3: Update the DNS record for your instance

Point a DNS record to the load balancer IP of the cluster (found from the AWS console).

### Step 4 (Optional): Create an RDS instance

Inside the `.infra` folder, create a directory called `rds`. In this directoy, add the following `main.tf` file:

```hcl
module "eks" {
  source = "../../../modules/eks"

  aws_region = "us-east-2" # TODO: your AWS region
  aws_profile = "default" # TODO: your AWS profile, if not default
  env_name = "production" # TODO: the name of your environment
  vpc_id = "" # TODO: the VPC ID, output from the step above
  vpc_cidr_block = "" # TODO: the VPC CIDR block from above
  database_subnets = [] # TODO: fill these out with the database subnet IDs from above
}
```

### Step 5: Install Porter Helm chart

Finally, inside the `.infra` folder, create a directory called `porter`. In this directory, add the following `values.yaml` chart:

```yaml
image:
  tag: "v0.15.3" # TODO: latest porter image tag
ingress:
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  enabled: true
  hosts:
    - host: your-domain.example.com # TODO: your domain
      paths:
        - "/"
  tls:
    - secretName: porter-cert-tls
      hosts:
        - your-domain.example.com # TODO: your domain
server:
  url: https://your-domain.example.com # TODO: your domain
  # TODO: add a cookie secret of the form <16-digits>;<16-digits>
  # This can be generated via: echo "$(cat /dev/urandom | base64 | head -c 16);$(cat /dev/urandom | base64 | head -c 16)"
  cookieSecret: ""
  # TODO: add a token encryption key, 32 random digits
  # This can be generated via: echo "$(cat /dev/urandom | base64 | head -c 32)"
  tokenEncryptionKey: ""
  # TODO: add a DB encryption key, 32 random digits
  # This can be generated via: echo "$(cat /dev/urandom | base64 | head -c 32)"
  dbEncryptionKey: ""
  instanceName: production # TODO: your environment name
  # googleLogin:
  #   enabled: true
  #   clientId: ""
  #   clientSecret: ""
  #   restrictedDomain: ""
  basicLogin:
    enabled: true
  postgres:
    # TODO: fill out host, db name, user, and password for database instance
    host: my-host
    name: porter
    user: porter
    password: porter
  githubApp:
    enabled: true
    clientId: ""
    clientSecret: ""
    webhookSecret: ""
    name: ""
    id: ""
    privateKey: |
      -----BEGIN RSA PRIVATE KEY-----
      TODO: PRIVATE KEY CONTENTS
      -----END RSA PRIVATE KEY-----
```

Then, run `helm install porter ../charts/porter --values values.yaml`.
