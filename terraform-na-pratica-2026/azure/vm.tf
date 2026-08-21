# ---------------------------------------------------------------
# Passo 3 do video: a VM que responde no navegador.
# ---------------------------------------------------------------
resource "azurerm_network_interface" "lab" {
  name                = "${var.prefixo}-nic"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "interna"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lab.id
  }
}

resource "azurerm_network_interface_security_group_association" "lab" {
  network_interface_id      = azurerm_network_interface.lab.id
  network_security_group_id = azurerm_network_security_group.lab.id
}

resource "azurerm_linux_virtual_machine" "lab" {
  name                  = "${var.prefixo}-vm-web"
  location              = azurerm_resource_group.lab.location
  resource_group_name   = azurerm_resource_group.lab.name
  size                  = "Standard_B1s"
  admin_username        = var.admin_user
  network_interface_ids = [azurerm_network_interface.lab.id]

  admin_ssh_key {
    username   = var.admin_user
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  custom_data = base64encode(file("${path.module}/cloud-init.yaml"))

  tags = {
    projeto   = "aula-terraform"
    descartar = "sim"
  }
}
