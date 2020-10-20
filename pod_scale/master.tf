resource "azurerm_public_ip" "pip" {
  name                = "kn-master-pip"
  resource_group_name = "alekhaneja_knative_rg"
  location            = "eastus"
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "main" {
  name                = "kn-master-nic1"
  resource_group_name = "alekhaneja_knative_rg"
  location            = "eastus"

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = "kn-master-vm"
  resource_group_name             = "alekhaneja_knative_rg"
  location                        = "eastus"
  size                            = "Standard_D8s_v3"
  admin_username                  = "adminuser"
  
  network_interface_ids = [
    azurerm_network_interface.main.id,
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
    name              = "kn-master_myosdisk1"
    caching           = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  
  provisioner "file" {
    source      = "masterscripts/"
    destination = "/tmp/"
  }
  
  provisioner "remote-exec" {
    inline = [
	  "chmod +x /tmp/prerequisites.sh kubeadmin",
	  "sudo /tmp/prerequisites.sh kubeadmin",
	  "CURRENT_IP=$(hostname -i)",
	  "chmod +x /tmp/vm_master_install_modify.sh",
	  "sudo /tmp/vm_master_install_modify.sh  $CURRENT_IP",
	  "chmod +x /tmp/helm_install_modify.sh",
	  "sudo /tmp/helm_install_modify.sh",
	  "export PATH=$PATH:/usr/local/bin/",
	  "chmod +x /tmp/install_tiller_modify.sh",
	  "sudo /tmp/install_tiller_modify.sh",
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
