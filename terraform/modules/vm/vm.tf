resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_id
  }
}

data "azurerm_image" "projectImage" {
  name                = var.vm_image_name
  resource_group_name = var.resource_group
}


resource "azurerm_linux_virtual_machine" "linux_vm" {
  name                = var.vm_name
  location            = var.location
  resource_group_name = var.resource_group
  size                = "Standard_DS2_v2"
  admin_username      = "vmuser"
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id
  ]
  admin_ssh_key {
    username = "vmuser"
    #Use the actual public key itself when using Terraform in the CI/CD pipeline.
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCDVISFRUvrzI0n8vgB4YCKYvqv6c+kcEo78quaOWj2484aBo0Ualye8m5ZrSv8xzBp97BdvLO2xQ8J1blZgCWw2JeTSaUQ+pyRFtOAUbQYS9pagJdxOh1ia2+h4OrGbAm9SnUn7niNaWxubkonY1pXvtBAvrAlg40kJVkZmkORfwCLo2AMjv+rtcK7LaB0pEqO3uG+y77Of6syH50qlSUI45jdympSlRHh2g4bNnrqcU92P9iAWLH2qo/eVC4sTcI/W946pdIQL82dpSx0WzlJBZ9UZpgOvBnuDMa8AP0PZiyuYJl3WxyZ0t1Ceygzz5wyPmMRkxyOljWQkJBe0sQDx5IW/ZZ+f5ISl/TcL6TjFPxHQWVR711uRQ73fnBUgo2PVLtE4kTPQCv8EeHMlrbUQQLpBRjOQVnPJlIfGZiAqzR2jCrTCJyiWI7SblLdM9OUwWf0bRJFKRqdVbHLPQG5WldPQWB5b8xTlZvtnSeyeeeUwW1BOMjg3orIOFFSitU= tamtt5@LPP00117561C"
    # On Azure Pipeline this file will be copy from Secure File
    # public_key = file("~/.ssh/id_rsa.pub")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = data.azurerm_image.projectImage.id
  # source_image_reference {
  #   publisher = "Canonical"
  #   offer     = "UbuntuServer"
  #   sku       = "18.04-LTS"
  #   version   = "latest"
  # }
}

locals {
  src_file = "${path.module}/setup_agent.sh"

  script_content = base64encode(
    replace(file(local.src_file),
    "AZURE_PAT", var.azure_devops_pat)
  )
}

resource "azurerm_virtual_machine_extension" "linux_vm_ext" {
  name                 = "${var.vm_name}-configAzureDevOpsVM"
  virtual_machine_id   = azurerm_linux_virtual_machine.linux_vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  protected_settings = <<PROT
  {
      "script": "${local.script_content}"
  }
  PROT
}
