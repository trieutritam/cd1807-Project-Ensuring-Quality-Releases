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
  admin_username      = "tamtt5"
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id
  ]
  admin_ssh_key {
    username = "tamtt5"
    #Use the actual public key itself when using Terraform in the CI/CD pipeline.
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1SJYQHr5ibdCtPq3ovp6BB0pAv2nWkhUc62aSNbVvK4NbThPRlaPVFJapDHhROtqHXe50xwecvg9VQmuklHvNKrMBoKU6RxeskfLUY6/stzs6mH3yeQLEzH/YxBcHvlh2Ks7OC6qSC9lIISlkysemYeMANrkb2bm1J6eN0gXzNoZcioWQWq98OYaz9JQI+4jiDOrionA17Tbcw+aH2sOOTvTjBZ6lM9VxV3RuS0UvT5tTid6YPn390RufvNOUNh4QKXjn6EozwTSp0x++OBUVS8E0jRX4poO2Fb8N+xC5zFP2i+G/5vtl3X5K0OwfCV7qru3+q/Dsy9Yn4aGQEANJ0nsKPg8i7z+H3f99E8oyXbJGNDOuuKUTUiwHtzylpZEqWI1dwxTyZc1fiyR3TE1ru9mMdAfV5+gMdSnAOGihGonyKvlwvoLXlXxKeU7XGp4dLh9jcgbD+aR1S/fh5vt76Exj7Dp+oiM7hZ5WWJpz26rO0xy0oB0lzkiS9Z839nk= tamtt@tamtt-pc"
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
