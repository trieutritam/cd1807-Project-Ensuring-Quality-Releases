packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 1"
    }
  }
}

variable "client_id" {
  type    = string
  default = "${env("TF_VAR_client_id")}"
}

variable "client_secret" {
  type    = string
  default = "${env("TF_VAR_client_secret")}"
}

variable "subscription_id" {
  type    = string
  default = "${env("TF_VAR_subscription_id")}"
}

source "azure-arm" "image_source" {
  azure_tags = {
    project = "Deploying a Web Server in Azure"
  }
  client_id                         = "${var.client_id}"
  client_secret                     = "${var.client_secret}"
  image_offer                       = "0001-com-ubuntu-server-jammy"
  image_publisher                   = "canonical"
  image_sku                         = "22_04-lts"
  location                          = "East US"
  managed_image_name                = "azgent-vm-image"
  managed_image_resource_group_name = "Azuredevops"
  os_type                           = "Linux"
  subscription_id                   = "${var.subscription_id}"
  vm_size                           = "Standard_B1s"
  ssh_username                      = "vmuser"
  ssh_password                      = "VmUser@123"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.azure-arm.image_source"]

  provisioner "file" {
    source = "setup_devops_agent.sh"
    destination = "/tmp/setup_devops_agent.sh"
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"

    // inline          = [
    //   "sudo apt-get install -y openjdk-17-jdk",
    //   "sudo apt-get install -y python3-pip unzip chromium-browser selenium",
    //   "cp /tmp/azuredevops_rsa ./",
    //   "cp /tmp/azuredevops_rsa.pub ./",
    //   "mkdir -p azagent",
    //   "cd azagent",
    //   "curl -fkSL -o vstsagent.tar.gz https://vstsagentpackage.azureedge.net/agent/3.238.0/vsts-agent-linux-x64-3.238.0.tar.gz",
    //   "tar -zxvf vstsagent.tar.gz",
    //   "cp /tmp/setup_devops_agent.sh ./setup_devops_agent.sh"
    // ]
    script = "./setup-server.sh"
    
    inline_shebang  = "/bin/sh -x"
  }

}
