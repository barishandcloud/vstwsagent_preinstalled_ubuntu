resource "random_pet" "rg-name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  #provider = azurerm.msys_azure
  name     = random_pet.rg-name.id
  location = var.resource_group_location
}


# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "myVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "vm1pip" {
  name                = "vm1pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}


# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "mynsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "49.207.226.38"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "nic1" {
  name                = "nic1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm1pip.id
  }
}


# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nic_assoc1" {
  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

#locals {
#  custom_data = <<CUSTOM_DATA
#  #!/bin/bash
#  echo "Execute your super awesome commands here!"
#  mkdir test
#  CUSTOM_DATA
#  }

data "template_file" "script_run" {
    template = file("script.sh")
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "testagentvm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic1.id]
  size                  = "Standard_B1s"

  os_disk {
    name                 = "myOsDisk1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "testagentvm"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  #custom_data = base64encode(local.custom_data)
  custom_data = base64encode(data.template_file.script_run.rendered)
  
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("swarmvm.pub")
  }
}

