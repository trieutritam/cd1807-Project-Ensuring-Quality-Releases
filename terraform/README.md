# Project Starter

This repository contains the code for the **Ensuring Quality Releases** project of the cd1807 Ensuring Quality Releases (Quality Assurance) course taught by Nathan Anderson.

## How to use?

### Init required Azure environment variables

Copy the lab information from Udemy and paste into file labinfo.txt then execute below command to init required variables

```
source init-vars.sh
```

### 1. Create VM Image using packer

```
cd packer
packer init server.pkr.hcl
packer build server.pkr.hcl
```

### 2. Provision Dev Environment

```
cd terraform
terraform init
terraform plan
terraform apply
```

## Suggestions and Corrections

Feel free to submit PRs to this repo should you have any proposed changes.
