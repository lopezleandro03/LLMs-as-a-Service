variable "environment_name" {
    description = "The name of the environment"
    type        = string
}

variable "location" {
    description = "The location/region of the AI Hub"
    type        = string
}

variable "resource_group_id" {
    description = "The ID of the resource group to deploy the AI Hub into"
    type        = string
}

variable "key_vault_id" {
    description = "The ID of the key vault to use for the AI Hub"
    type        = string
}

variable "application_insights_id" {
    description = "The ID of the application insights to use for the AI Hub"
    type        = string
}

variable "storage_account_id" {
    description = "The ID of the storage account to use for the AI Hub"
    type        = string
}

variable "tags" {
    description = "A map of tags to add to all resources"
    type        = map(string)
}