#########################################
# Azure AI Project
#########################################
resource "azapi_resource" "project" {
  type      = "Microsoft.MachineLearningServices/workspaces@2023-10-01"
  name      = "aiproject-${var.environment_name}-${var.location}"
  parent_id = var.resource_group_id
  location  = var.location
  identity {
    type = "SystemAssigned"
  }
  
  body = jsonencode({
    kind     = "Project"
    properties = {
      hubResourceId = var.hub_id
    }
  })

  schema_validation_enabled = false
}