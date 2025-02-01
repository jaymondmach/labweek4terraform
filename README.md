# Lab Week 4 Terraform

### Jaymond Mach | A01360997

# Terraform Configuration for EC2 Instance

This repository contains Terraform configuration files to provision an EC2 instance with a VPC, subnet, security group, and other necessary resources. The instance is configured using cloud-init to install `nginx` and `nmap`.

---

## General Setup

### Prerequisites

1. **AWS Account**: Ensure you have an AWS account and the necessary permissions to create EC2 instances, VPCs, and related resources.
2. **Terraform**: Install Terraform on your local machine. Download it from [here](https://www.terraform.io/downloads.html).
3. **AWS CLI**: Install the AWS CLI and configure it with your credentials:
   ```bash
   aws configure
   ```
4. **SSH Key Pair**: Create an SSH Key pair for accessing the EC2 instance.

## Generate a New SSH Key Pair

Run the following command to generate a new SSH key pair:

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ~/.ssh/acit4640wk4
```

Replace `your_email@example.com` with your email or a comment.

The `-f ~/.ssh/acit4640wk4` option specifies the filename for the key pair (private key: `acit4640wk4`, public key: `acit4640wk4.pub`).

## Set Correct Permissions

Ensure the private key has the correct permissions:

```bash
chmod 400 ~/.ssh/acit4640wk4
```

## Add the Public Key to cloud-config.yaml

Edit the `cloud-config.yaml` file in the scripts directory and add the public key:

```yaml
#cloud-config
users:
  - name: ubuntu
    groups: sudo
    shell: /bin/bash
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2E... your_email@example.com
```

## Terraform Commands

### Initialize Terraform

Run the following command to initialize Terraform and download the required providers:

```bash
terraform init
```

### Format and Validate Configuration

Format the configuration files to ensure consistent style:

```bash
terraform fmt
```

Validate the configuration to check for syntax errors:

```bash
terraform validate
```

### Plan the Configuration

Generate an execution plan to see what resources Terraform will create:

```bash
terraform plan
```

### Apply the Configuration

Apply the configuration to create the resources:

```bash
terraform apply
```

### Destroy the Configuration

To destroy all resources created by Terraform, run:

```bash
terraform destroy
```

## Accessing the EC2 Instance

### Retrieve the Public IP or DNS

After applying the configuration, retrieve the public IP or DNS of the instance:

```bash
terraform output instance_ip_addr
```

### SSH into the Instance

Use the private key to SSH into the instance:

```bash
ssh -i ~/.ssh/acit4640wk4 ubuntu@<public_ip_or_dns>
```

### Verify Installed Packages

Check that `nginx` and `nmap` are installed:

```bash
nginx -v
nmap --version
```

## Additional Instructions

### Cloud-Init Configuration

The `cloud-config.yaml` file is used to:

- Add the SSH public key for the `ubuntu` user.
- Install `nginx` and `nmap` packages.

### Security Group Configuration

The security group allows:

- SSH access (port 22) from any IP.
- HTTP access (port 80) from any IP.
- All outbound traffic.

## Outputs

Terraform outputs the public IP and DNS of the EC2 instance:

```hcl
output "instance_ip_addr" {
  description = "The public IP and DNS of the web EC2 instance."
  value = {
    "public_ip" = aws_instance.web.public_ip
    "dns_name"  = aws_instance.web.public_dns
  }
}
```

## Troubleshooting

### SSH Connection Issues

- Ensure the private key has the correct permissions (`chmod 400 ~/.ssh/acit4640wk4`).
- Verify the public key is correctly added to the `cloud-config.yaml` file.
- Check the instance’s security group to ensure it allows SSH access (port 22) from your IP.

### Terraform Errors

- Run `terraform validate` to check for syntax errors.
- Ensure the AWS provider is correctly configured with the required permissions.
