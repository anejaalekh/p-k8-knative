provider "azurerm" {
    version="2.30.0"
	features {}
}

# create resource group
resource "azurerm_resource_group" "rg"{
    name = "alekhaneja_knative_rg"
    location = "eastus"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "kn-master-tf-03-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "https"
    priority                   = 1010
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "443"
    destination_address_prefix = "*"
    
  }
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "http"
    priority                   = 1030
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "80"
    destination_address_prefix = "*"
    
  }
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "ssh"
    priority                   = 1020
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "22"
    destination_address_prefix = "*"
    
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-terraform-eastus-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.1.0.0/24"]

}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.1.0.0/24"]
}

###############################################################
# create resource group1
resource "azurerm_resource_group" "rg1"{
    name = "alekhaneja_knative_rg1"
    location = "eastus2"
}

resource "azurerm_virtual_network" "main1" {
  name                = "vnet-terraform-eastus-2"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  address_space       = ["10.1.1.0/24"]

}

resource "azurerm_subnet" "secondsb" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.main1.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_network_security_group" "nsg1" {
  name                = "kn-master-tf-03-nsg1"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "https"
    priority                   = 1010
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "443"
    destination_address_prefix = "*"
    
  }
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "http"
    priority                   = 1030
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "80"
    destination_address_prefix = "*"
    
  }
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "ssh"
    priority                   = 1020
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "22"
    destination_address_prefix = "*"
    
  }
}
######################################

resource "azurerm_resource_group" "rg2"{
    name = "alekhaneja_knative_rg2"
    location = "westus2"
}

resource "azurerm_virtual_network" "main2" {
  name                = "vnet-terraform-westus-2"
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name
  address_space       = ["10.0.0.0/24"]

}

resource "azurerm_subnet" "thirdsb" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg2.name
  virtual_network_name = azurerm_virtual_network.main2.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "nsg2" {
  name                = "kn-master-tf-03-nsg2"
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "https"
    priority                   = 1010
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "443"
    destination_address_prefix = "*"
    
  }
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "http"
    priority                   = 1030
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "80"
    destination_address_prefix = "*"
    
  }
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "ssh"
    priority                   = 1020
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "22"
    destination_address_prefix = "*"
    
  }
}

##################################################

resource "azurerm_virtual_network_peering" "peering" {
  name                         = "peering-to-1-to-2"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.main.name
  remote_virtual_network_id    = azurerm_virtual_network.main1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  allow_gateway_transit = true
}

resource "azurerm_virtual_network_peering" "peering1" {
  name                         = "peering-to-2-to-1"
  resource_group_name          = azurerm_resource_group.rg1.name
  virtual_network_name         = azurerm_virtual_network.main1.name
  remote_virtual_network_id    = azurerm_virtual_network.main.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  allow_gateway_transit = true
}
###################################################################
resource "azurerm_virtual_network_peering" "peering2" {
  name                         = "peering-to-1-to-3"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.main.name
  remote_virtual_network_id    = azurerm_virtual_network.main2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  allow_gateway_transit = true
}

resource "azurerm_virtual_network_peering" "peering3" {
  name                         = "peering-to-3-to-1"
  resource_group_name          = azurerm_resource_group.rg2.name
  virtual_network_name         = azurerm_virtual_network.main2.name
  remote_virtual_network_id    = azurerm_virtual_network.main.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  allow_gateway_transit = true
}
#################################################
resource "azurerm_virtual_network_peering" "peering4" {
  name                         = "peering-to-2-to-3"
  resource_group_name          = azurerm_resource_group.rg1.name
  virtual_network_name         = azurerm_virtual_network.main1.name
  remote_virtual_network_id    = azurerm_virtual_network.main2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  allow_gateway_transit = true
}

resource "azurerm_virtual_network_peering" "peering5" {
  name                         = "peering-to-3-to-2"
  resource_group_name          = azurerm_resource_group.rg2.name
  virtual_network_name         = azurerm_virtual_network.main2.name
  remote_virtual_network_id    = azurerm_virtual_network.main1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  allow_gateway_transit = true
}


