##############################################################
# resource group

resource "azurerm_resource_group" "adr" {
    name = "rg-${local.system}"
    location = var.location

    tags = local.common_tags
}

# resource group
##############################################################

#############################################
# virtual network
resource "azurerm_virtual_network" "adr" {
    name = "vnet-${local.system}"
    location = var.location
    resource_group_name = azurerm_resource_group.adr.name
    address_space = var.vnet_address_space

    tags = local.common_tags
}

resource "azurerm_subnet" "adr" {
    name = "subnet-${local.system}"
    resource_group_name = azurerm_resource_group.adr.name
    virtual_network_name = azurerm_virtual_network.adr.name
    address_prefixes = var.subnet_address_space
}

#
#############################################


#############################################
# VM

# VM ssh key
resource "tls_private_key" "adr" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "azurerm_public_ip" "adr" {
    name = "public-ip-${local.system}"
    location = var.location
    resource_group_name = azurerm_resource_group.adr.name
    allocation_method   = "Static"
}

resource "azurerm_network_security_group" "adr" {
    name = "nsg-${local.system}"
    location = var.location
    resource_group_name = azurerm_resource_group.adr.name

    # ingress rules
    security_rule {
        name = "ssh"
        priority = 300
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"

        source_address_prefix = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name = "http"
        priority = 310
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "80"

        source_address_prefix = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name = "https"
        priority = 320
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "443"

        source_address_prefix = "*"
        destination_address_prefix = "*"
    }

    # network security group has built-in 65001 AllowInternetOutBound access
    # no need for egress rules for ubuntu security updates

    tags = local.common_tags
}

resource "azurerm_network_interface" "adr" {
    name = "nic-${local.system}"
    location = var.location
    resource_group_name = azurerm_resource_group.adr.name

    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.adr.id
        private_ip_address_allocation = "Dynamic"

        public_ip_address_id = azurerm_public_ip.adr.id
    }
}

resource "azurerm_network_interface_security_group_association" "adr" {
    network_interface_id = azurerm_network_interface.adr.id
    network_security_group_id = azurerm_network_security_group.adr.id
}

resource "azurerm_linux_virtual_machine" "adr" {
    name = "vm-${local.system}"
    location = var.location
    resource_group_name = azurerm_resource_group.adr.name
    size = var.vm_size

    admin_username = "${local.system}-admin"
    network_interface_ids = [azurerm_network_interface.adr.id]
    
    admin_ssh_key {
        username = "${local.system}-admin"
        public_key = tls_private_key.adr.public_key_openssh
    }

    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    # az vm image list --publisher Canonical --sku 20_04-lts-gen2 --all
    source_image_reference {
        publisher = "Canonical"
        offer = "0001-com-ubuntu-server-focal"
        sku = "20_04-lts-gen2"
        #version = "20.04.202302090"
        version = "latest"
    }
}

resource "azurerm_dns_a_record" "adr" {
    name = local.system
    zone_name = "azure.procap360.com"
    resource_group_name = "rg-procap360-global"
    ttl = 300
    records = [azurerm_public_ip.adr.ip_address]
}

# VM for adr
#############################################