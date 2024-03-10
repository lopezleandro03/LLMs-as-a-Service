locals {
  tags                         = { azd-env-name : var.environment_name }
  sha                          = base64encode(sha256("${var.environment_name}${var.location}${data.azurerm_client_config.current.subscription_id}"))
  resource_token               = substr(replace(lower(local.sha), "[^A-Za-z0-9_]", ""), 0, 13)
  name_no_symbols              = replace(var.environment_name, "-", "")

  # By the time of writing this code, LLMs in the Model Catalogue are not available in all regions, make sure you select
  # one of the available regions for the models you want to deploy or use these flags to control which models to deploy
  deploy_llama_2_7b_chat       = false # TODO: https://github.com/lopezleandro03/genai-models-as-a-service/issues/1
  deploy_mistral_large         = true
}

resource "azurecaf_name" "rg_name" {
  name          = var.environment_name
  resource_type = "azurerm_resource_group"
  random_length = 0
  clean_input   = true
}

#########################################
# Deploy resource group
#########################################
resource "azurerm_resource_group" "rg" {
  name     = azurecaf_name.rg_name.result
  location = var.location
  // Tag the resource group with the azd environment name
  // This should also be applied to all resources created in this module
  tags = { azd-env-name : var.environment_name }
}

#########################################
# Storage Account
#########################################
resource "azurerm_storage_account" "storage" {
  name                     = "stg${local.name_no_symbols}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags
}

#########################################
# Key Vault
#########################################
resource "azurerm_key_vault" "kv" {
  name                     = "kv-${var.environment_name}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku_name                 = "standard"
  tenant_id                = data.azurerm_client_config.current.tenant_id
  tags                     = local.tags
}

#########################################
# Application Insights
#########################################
resource "azurerm_application_insights" "ai" {
  name                     = "ai-${var.environment_name}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  application_type         = "web"
  tags                     = local.tags
}

#########################################
# Azure AI Hub
#########################################
module "ai_hub" {
  source = "./modules/ai_hub"
  environment_name        = var.environment_name
  location                = var.location
  resource_group_id       = azurerm_resource_group.rg.id
  key_vault_id            = azurerm_key_vault.kv.id
  application_insights_id = azurerm_application_insights.ai.id
  storage_account_id      = azurerm_storage_account.storage.id
  tags                    = local.tags
  
}

#########################################
# Azure AI Project
#########################################
module "ai_project" {
  source = "./modules/ai_project"
  environment_name = var.environment_name
  location         = var.location
  resource_group_id = azurerm_resource_group.rg.id
  hub_id            = module.ai_hub.id
  tags              = local.tags
}

##########################################
# Model: Mistral large
##########################################
module "mistral_large" {
  count = local.deploy_mistral_large ? 1 : 0

  source = "./modules/ai_model_serverless"
  environment_name = var.environment_name
  location         = var.location
  resource_group_id = azurerm_resource_group.rg.id
  project_id        = module.ai_project.id
  model = {
    id = "azureml://registries/azureml-mistral/models/Mistral-large"
    name = "Mistral-large"
    marketplace_publisher_id = "000-000"
    marketplace_offer_id = "mistral-ai-large-offer"
    marketplace_plan_id  = "mistral-large-2402-plan"
  }
  tags = local.tags
}

#########################################
# Model: Meta Llama-2-7b-chat
#########################################
module "llama-2-7b-chat" {
  count = local.deploy_llama_2_7b_chat ? 1 : 0

  source = "./modules/ai_model_serverless"
  environment_name = var.environment_name
  location         = var.location
  resource_group_id = azurerm_resource_group.rg.id
  project_id        = module.ai_project.id
  model = {
    id = "azureml://registries/azureml-meta/models/Llama-2-7b-chat"
    name = "Llama-2-7b-chat"
    # marketplace_publisher_id = "metagenai"
    marketplace_publisher_id = "metagenai"
    marketplace_offer_id = "meta-llama-2-7b-chat-offer"
    marketplace_plan_id  = "meta-llama-2-7b-chat-plan"
  }
  tags = local.tags
}