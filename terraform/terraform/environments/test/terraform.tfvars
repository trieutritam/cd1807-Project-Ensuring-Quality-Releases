# Azure subscription vars
#region These vars will be set by ENV variables
# subscription_id = ""
# client_id       = ""
# client_secret   = ""
# tenant_id       = ""

# # Azure DevOps Personal Access Token
# azure_devops_pat = ""

#endregion End ENV vars

# Resource Group/Location
location         = "East US"
resource_group   = "Azuredevops"
application_type = "myApplication"

# Network
virtual_network_name = ""
address_space        = ["10.5.0.0/16"]
address_prefix_test  = "10.5.1.0/24"
