provider "azurerm" {
    
    default_tags {
        tags = {
            owner = "romegioli"
        }
    }
}

resource "azurerm_resource_group" "iac_rg" {
  name     = "BU-MT"
  location = "westeurope"
}

resource "azurerm_virtual_network" "iac_vnet" {
  name                = "IACVNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.iac_rg.location
  resource_group_name = azurerm_resource_group.iac_rg.name
}

resource "azurerm_subnet" "iac_subnet" {
  name                 = "IACSubnet"
  resource_group_name  = azurerm_resource_group.iac_rg.name
  virtual_network_name = azurerm_virtual_network.iac_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "iac_nic" {
  name                = "IACNIC"
  location            = azurerm_resource_group.iac_rg.location
  resource_group_name = azurerm_resource_group.iac_rg.name

  ip_configuration {
    name                          = "IACNICConfig"
    subnet_id                     = azurerm_subnet.iac_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "iac_vm" {
  name                  = "IACVM"
  location              = azurerm_resource_group.iac_rg.location
  resource_group_name   = azurerm_resource_group.iac_rg.name
  network_interface_ids = [azurerm_network_interface.iac_nic.id]
  vm_size               = "Standard_B2s"  # 2 CPUs, 4 GB RAM

  storage_image_reference {
    publisher = "ntegralinc1586961136942"
    offer     = "ntg_centos_9_stream"
    sku       = "ntg_centos_9_stream_gen2"
    version   = "latest"
  }

  os_profile {
    computer_name  = "IAC"
    admin_username = "azureuser"
    linux_configuration {
      disable_password_authentication = true
      ssh_keys {
        path     = "/home/azureuser/.ssh/authorized_keys"
        key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCmwiDx6ROd69CI36U/PH8zi2l4KQIhnOQEFrLlLQJA8DB9I0drAZNzmXCICcQfMdlEeF2K9Z8Kfv+np4jOpxKbJ3cW3aWlOb+SKEo3u574sPqJ4aRE8qkjvCPlU9j2qbmyC8Fm5wkYq5cawoZMQWDgq5V4mmL0C0rDtHhhjvIsAS1DSH8nJiq20AsyhQGFTywCqQBOVDDlOkvEGOGDYuOsTwSWGSrmRA/mAS2TZy7bT4j17XOQYC4cJ9DQBapWjVRnf3fhqK5BiAnD1WIFtBE7H5m1HJaebp8UXX+OYXvCHmgy/gE/UDkFLOin4OmKVoQ2MKO0U1PblX/eqyeN+1tVnYeAQNE5qsVjw0q/eVN0zKA6DUyegZENgDs7j+wSgNqV51YYA1o4pYMxcAD0FWYEdwvA0ra9aWApuSS6aRKJozZjThEcE8FJFjBzm5VXHR2+KiJVLIwxOs9lRiu4HT3/uR6A0i3A8jz/UtIeztwYAnVz3OLhTRR24nEiK6Emuek= generated-by-azure"
      }
      provision_vm_agent = true
      patch_settings {
        patch_mode         = "ImageDefault"
        assessment_mode    = "ImageDefault"
      }
    }
  }

  storage_os_disk {
    name              = "IAC_OsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = 20
  }

  tags = {
    name = "IaC"
  }
}

