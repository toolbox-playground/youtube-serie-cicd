# Setup OIDC com Azure - Passo a Passo

> **Pré-requisitos:** Azure CLI instalado e logado

## 1. Criar App Registration no Microsoft Entra ID

```bash
# Criar o App Registration
az ad app create --display-name "github-actions-oidc-SEU-REPO"
```

**📝 Anote os valores:**
- `appId` = `AZURE_CLIENT_ID`
- `tenant` = `AZURE_TENANT_ID`

## 2. Criar Federated Credential

```bash
# Substitua pelos seus valores
export APPLICATION_ID="seu-app-id-aqui"
export GITHUB_ORG="sua-org"
export GITHUB_REPO="seu-repo"
export BRANCH="main"  # ou develop, etc.

# Criar credencial federada
az ad app federated-credential create \
  --id $APPLICATION_ID \
  --parameters '{
    "name": "github-actions-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'$GITHUB_ORG'/'$GITHUB_REPO':ref:refs/heads/'$BRANCH'",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

### Alternativa: Múltiplas branches

```bash
# Para permitir qualquer branch (menos seguro)
az ad app federated-credential create \
  --id $APPLICATION_ID \
  --parameters '{
    "name": "github-actions-all-branches",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'$GITHUB_ORG'/'$GITHUB_REPO':ref:refs/heads/*",
    "audiences": ["api://AzureADTokenExchange"]
  }'

# Ou para pull requests
az ad app federated-credential create \
  --id $APPLICATION_ID \
  --parameters '{
    "name": "github-actions-pull-requests",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'$GITHUB_ORG'/'$GITHUB_REPO':pull_request",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

## 3. Criar Service Principal e Atribuir Permissões

```bash
# Criar Service Principal
az ad sp create --id $APPLICATION_ID

# Atribuir role na subscription (ajuste conforme necessário)
export SUBSCRIPTION_ID="sua-subscription-id"

# Contributor (acesso amplo)
az role assignment create \
  --role "Contributor" \
  --assignee $APPLICATION_ID \
  --scope "/subscriptions/$SUBSCRIPTION_ID"

# Ou mais restritivo: apenas um resource group
export RESOURCE_GROUP="meu-rg"
az role assignment create \
  --role "Contributor" \
  --assignee $APPLICATION_ID \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP"
```

## 4. Configurar Secrets no GitHub

**Ir para:** `Settings → Secrets and variables → Actions → New repository secret`

**Criar os seguintes secrets:**
- `AZURE_CLIENT_ID`: O `appId` do App Registration
- `AZURE_TENANT_ID`: O `tenant` ID do seu Azure AD
- `AZURE_SUBSCRIPTION_ID`: ID da sua subscription Azure

**⚠️ Importante:** Não crie `AZURE_CLIENT_SECRET` — o OIDC não usa!

## 5. Testar a Configuração

Use o workflow `nivel4-oidc-azure.yml` para testar:

```yaml
- name: Test OIDC Authentication
  uses: azure/login@v2
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

- name: Verificar autenticação
  run: az account show
```

## 6. Troubleshooting

### Erro: "No subscription found"
```bash
# Verificar se o Service Principal tem acesso à subscription
az role assignment list --assignee $APPLICATION_ID
```

### Erro: "AADSTS70021: No matching federated identity record found"
- Verificar se o `subject` no federated credential está correto
- Confirmar que está executando na branch/repo corretos
- Verificar se `permissions: id-token: write` está no workflow

### Erro: "AADSTS50105: The signed in user is not assigned to a role"
```bash
# O Service Principal precisa de uma role assignment
az role assignment create --role "Reader" --assignee $APPLICATION_ID --scope "/subscriptions/$SUBSCRIPTION_ID"
```

## 7. Melhores Práticas de Segurança

### ✅ Recomendado:
- **Federated credentials específicos** por branch/ambiente
- **Least privilege:** roles mínimas necessárias
- **Resource group scope:** em vez de subscription inteira
- **Environment protection:** para produção

### ❌ Evitar:
- Subject genérico: `repo:org/*` (muito permissivo)
- Contributor na subscription inteira (quando não necessário)
- Federated credential para "*" branches

## 8. Exemplo de Configuração Avançada

```bash
# Diferentes environments com different scopes
# Production: apenas main branch, resource group específico
az ad app federated-credential create \
  --id $APPLICATION_ID \
  --parameters '{
    "name": "github-production",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'$GITHUB_ORG'/'$GITHUB_REPO':environment:production",
    "audiences": ["api://AzureADTokenExchange"]
  }'

# Staging: develop branch
az ad app federated-credential create \
  --id $APPLICATION_ID \
  --parameters '{
    "name": "github-staging", 
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'$GITHUB_ORG'/'$GITHUB_REPO':environment:staging",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

---

## 🎯 Resultado Final

✅ **Zero client secrets** armazenados  
✅ **Tokens temporários** (expiram em minutos)  
✅ **Trust policy restritiva** (apenas repo/branch autorizados)  
✅ **Auditoria completa** via Azure AD logs  
✅ **Zero manutenção** (sem rotação manual)  

**🔐 Segurança máxima com mínimo overhead!**