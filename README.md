# Deploy-Apache-Web-Server-using-Terraform-IaC
This script is a terroform script used in deploying an infrastructure on aws using terraform.

The commands to run after completion of the script are:
1. terraform init

The terraform init command will initialize the working directory containing Terraform configuration files and install any required plugins. 
Note: The terraform init command is safe to run multiple times, to bring the working directory up to date with changes in the configuration.

2. terraform plan

The terraform plan command creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure.
This will also help you know which changes to be made and which errors are there to be corrected.

3. terraform apply

Creates or updates infrastructure depending on the configuration files.
