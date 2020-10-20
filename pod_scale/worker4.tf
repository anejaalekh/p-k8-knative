resource "azurerm_public_ip" "knworker04pip" {
  name                = "kn-worker-04-pip"
  resource_group_name = "alekhaneja_knative_rg"
  location            = "eastus"
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "knworker04ni" {
  name                = "kn-worker-04-nic1"
  resource_group_name = "alekhaneja_knative_rg"
  location            = "eastus"

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.knworker04pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "knworker04niasso" {
  network_interface_id      = azurerm_network_interface.knworker04ni.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "kn-worker-04" {
  name                            = "kn-worker-04-vm"
  resource_group_name             = "alekhaneja_knative_rg"
  location                        = "eastus"
  size                            = "Standard_D8s_v3"
  admin_username                  = "adminuser"
  
  network_interface_ids = [
    azurerm_network_interface.knworker04ni.id,
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
    name              = "kn-worker-04_myosdisk1"
    caching           = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  
  provisioner "file" {
    source      = "slave/scripts/"
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
