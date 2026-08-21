# aula-terraform — laboratório do vídeo "Terraform na prática 2026: IaC do zero"

Canal **TBX Tech** · [treinamentos.tbxtech.com.br](https://treinamentos.tbxtech.com.br)

Do `terraform init` ao `terraform destroy`: rede, VM e IP público de verdade, sem clicar no portal.

> ⚠️ **Isto cria recursos reais na nuvem.** A cota da conta gratuita não é imunidade: passou da cota, cobra.
> **Termine sempre com `terraform destroy`.**

---

## Estrutura

```
azure/   → laboratório do vídeo (provider azurerm ~> 5.1)
aws/     → o MESMO laboratório traduzido para AWS (provider aws ~> 6.0)
```

Abra os dois lado a lado. O Terraform é idêntico — o que muda é o `resource`. Essa é a tese do vídeo.

---

## Pré-requisitos

| Ferramenta | Como conferir |
|---|---|
| Terraform (linha 1.15.x recomendada) | `terraform -version` |
| Azure CLI | `az version` |
| Chave SSH | `ssh-keygen -t rsa -b 4096 -f ~/.ssh/tbx_lab` |

---

## Rodando (Azure)

```bash
az login
az account show --query id -o tsv     # copie este id

cd azure
cp terraform.tfvars.example terraform.tfvars
# edite terraform.tfvars: subscription_id e meu_ip_cidr (curl -s ifconfig.me)

terraform init
terraform plan
terraform apply

terraform output url                  # abra no navegador
```

**Quando terminar:**

```bash
terraform destroy
```

---

## O ciclo, em uma tabela

| Comando | O que faz |
|---|---|
| `init` | baixa o provider e escreve o `.terraform.lock.hcl` |
| `fmt` / `validate` | formata e valida a sintaxe (rode antes de commitar) |
| `plan` | mostra a diferença entre o que existe e o que você declarou |
| `apply` | executa o plano |
| `state list` | lista o que o Terraform acredita que existe |
| `destroy` | remove tudo que este state controla |

### Lendo o `plan` (a parte que ninguém ensina)

| Símbolo | Significado |
|---|---|
| `+` | vai criar |
| `-` | vai destruir |
| `~` | vai atualizar **no lugar**, sem downtime |
| `-/+` | **vai destruir e recriar** — procure o `# forces replacement` na saída |

Experimento sugerido depois do vídeo: mude uma `tag` (vira `~`) e depois mude o `admin_username` (vira `-/+`). É a diferença entre uma alteração cosmética e um incidente.

---

## As 7 regras para isso sobreviver em produção

1. **State remoto e travado** desde o segundo dia (Storage Account no Azure, S3 na AWS). State local só funciona enquanto você trabalha sozinho.
2. **O state contém segredo em texto claro.** Nunca commite; criptografe no backend; segredo de verdade vem de cofre (Key Vault / Secrets Manager).
3. **Nunca edite o state à mão.** Use `import` block e `terraform state rm`.
4. **Pine tudo:** `required_version`, `version` do provider, e commite o `.terraform.lock.hcl`.
5. **`fmt` e `validate` no pipeline, `plan` no pull request, `apply` só no merge.** Ninguém aplica da própria máquina.
6. **Módulo só na terceira repetição.** Abstrair cedo cria indireção que ninguém entende depois.
7. **Um state por ambiente**, isolado. Dev, homolog e prod não compartilham backend.

---

## Terraform ou OpenTofu?

Desde a versão 1.6 (2023) o Terraform é distribuído sob **BUSL 1.1** — código disponível, não open source. O **OpenTofu** é o fork da comunidade, hoje sob a Linux Foundation, com licença MPL 2.0. HCL e comandos são compatíveis na prática (`tofu` no lugar de `terraform`).

Recomendação: **aprenda Terraform**, porque é o que a vaga pede. Saber por que o OpenTofu existe é resposta de entrevista.

---

## Avisos

- `terraform.tfvars`, `*.tfstate` e chaves **não vão para o git** (ver `.gitignore`).
- `meu_ip_cidr = "0.0.0.0/0"` só é aceitável em laboratório descartável. Restrinja ao seu IP.
- Versões dos providers mudam rápido. O `azurerm` passou para a **v5 em julho/2026**; se algum argumento quebrar, confira o upgrade guide no Terraform Registry e abra uma issue aqui.

---

## Trilha completa

Terraform Express, Introdução a Pipelines CI/CD, Docker Fundamentals e GitHub Actions na Prática - **gratuitos** em [treinamentos.tbxtech.com.br](https://treinamentos.tbxtech.com.br).
