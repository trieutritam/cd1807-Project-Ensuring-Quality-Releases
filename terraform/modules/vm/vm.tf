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
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCs0SkXFbV5rIkezrktUJ731XIQJDeiI893h6xC2fcg1RKjToB6fuM5nUzSBzp3ceLj3fmPYAwVL0GxO3V73aEOawSvqolMF+LAkXBNRB8pt0tT41HlgTF5d1IAgINyVQc1dnomC+gn0haZu2moU6YhoHmWlZlL7GabFrd/vXKwfdi8QwykqQc6zq6lt/shN7G+TS0cZjly7RC51wmgscX8yuXUUVfBePlH0GGc1RIdso28uA+h8lxkUkrpjDqVXGZDpbf0nlY4tHRMJe7Fwm83gMLJ++BTsbY+g9MiNbr4Xb9fY4Hy45iowf/2pkfUxTFXHgGCmi7t5UQrrm3vUPkFmww1UHZg8l8zbTdmi/SDaD0LkNGTPl7nPwkx5aYCC4o+23iJLcuTfbhUg5hiThioubtMr1gGKej/qR9D5q2sG4iwuXmc8U8mLScK0rXLAZvj53NaUj8MCg4MzdqVZEmQv+9D9ETzjRb4pz5FDyYXfdnkrdNrJlZMokpDoPXDbQk= tamtt@tamtt-pc"
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
