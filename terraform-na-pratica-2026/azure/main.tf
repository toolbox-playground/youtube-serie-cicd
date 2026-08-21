# ---------------------------------------------------------------
# Passo 1 do video: o primeiro apply e so isto aqui.
# ---------------------------------------------------------------
resource "azurerm_resource_group" "lab" {
  name     = "rg-${var.prefixo}-aula-terraform"
  location = var.location

  tags = {
    projeto   = "aula-terraform"
    dono      = "tbx"
    descartar = "sim"
  }
}
