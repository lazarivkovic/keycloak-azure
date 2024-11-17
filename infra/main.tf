# Resource group for Linux VM (Keycloak)
resource "azurerm_resource_group" "keycloak_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Creating Virtual Network for Keycloak app
resource "azurerm_virtual_network" "keycloak_vnet" {
  name                = "keycloak-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.keycloak_rg.location
  resource_group_name = azurerm_resource_group.keycloak_rg.name
}

# Creating Subnet for Virtual Network
resource "azurerm_subnet" "keycloak_subnet" {
  name                 = "keycloak-vm-subnet"
  resource_group_name  = azurerm_resource_group.keycloak_rg.name
  virtual_network_name = azurerm_virtual_network.keycloak_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP for VM
resource "azurerm_public_ip" "keycloak_public_ip" {
  name                = "keycloak-ip"
  location            = azurerm_resource_group.keycloak_rg.location
  resource_group_name = azurerm_resource_group.keycloak_rg.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

# (NSG) with Security Rules for VM
resource "azurerm_network_security_group" "keycloak_nsg" {
  name                = "keycloak-vm-nsg"
  location            = azurerm_resource_group.keycloak_rg.location
  resource_group_name = azurerm_resource_group.keycloak_rg.name

  security_rule {
    name                       = "Allow_SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow_HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow_HTTPS"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow_Keycloak"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Interface
resource "azurerm_network_interface" "keycloak_nic" {
  name                = "keycloak-vm-nic"
  location            = azurerm_resource_group.keycloak_rg.location
  resource_group_name = azurerm_resource_group.keycloak_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.keycloak_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.keycloak_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.keycloak_nic.id
  network_security_group_id = azurerm_network_security_group.keycloak_nsg.id
}

# Generate SSH key
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Linux VM (Keycloak APP)
resource "azurerm_linux_virtual_machine" "keycloak-vm" {
  name                = "keycloak-vm"
  location            = azurerm_resource_group.keycloak_rg.location
  resource_group_name = azurerm_resource_group.keycloak_rg.name
  size                = "Standard_F2"
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.keycloak_nic.id,
  ]

  # Storage configuration
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Linux image configuration
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # SSH access configuration for VM
  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ssh.public_key_openssh
  }

}
