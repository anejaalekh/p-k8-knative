resource "azurerm_public_ip" "knworker088pip" {
  name                = "kn-worker-088-pip"
  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "knworker088ni" {
  name                = "kn-worker-088-nic1"
  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.thirdsb.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.knworker088pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "knworker088niasso" {
  network_interface_id      = azurerm_network_interface.knworker088ni.id
  network_security_group_id = azurerm_network_security_group.nsg2.id
}

resource "azurerm_linux_virtual_machine" "kn-worker-088" {
  name                            = "kn-worker-088-vm"
  resource_group_name             = azurerm_resource_group.rg2.name
  location                        = azurerm_resource_group.rg2.location
  size                            = "Standard_D8s_v3"
  admin_username                  = "adminuser"
  
  network_interface_ids = [
    azurerm_network_interface.knworker088ni.id,
  ]

  admin_ssh_key {
    username = "adminuser"
    public_key = file("D:/azure_scripts/id_rsa.pub")
  }

  source_image_reference {
    publisher = "cognosys"
    offer     = "centos-75"
    sku       = "centos-75"
    version   = "1.2019.0711"
  }
  
  plan {
    publisher = "cognosys"
    product = "centos-75"
    name = "centos-75"
}

  os_disk {
    name              = "kn-worker-088_myosdisk1"
    caching           = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  
  provisioner "file" {
    source      = "worker/scripts/"
    destination = "/tmp/"
  }
  
  provisioner "remote-exec" {
    inline = [
	  "chmod +x /tmp/prerequisites.sh",
	  "sudo /tmp/prerequisites.sh kubeadmin",
	  "chmod +x /tmp/vm_worker_install_modify.sh",
	  "sudo /tmp/vm_worker_install_modify.sh kubeadmin 10.1.0.4",
	  "sudo wget https://dl.google.com/go/go1.13.linux-amd64.tar.gz  && sudo tar -C /usr/local -xzf go1.13.linux-amd64.tar.gz",
	  "git clone https://github.com/rakyll/hey.git"
    ]
	on_failure = continue
  }
  
  connection {
    type = "ssh"
    user = "adminuser"
    private_key = file("D:/azure_scripts/id_rsa")
	host     = self.public_ip_address
  }
  
}
