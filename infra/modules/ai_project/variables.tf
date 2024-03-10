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

variable "hub_id" {
    description = "The ID of the AI Hub to deploy the AI Project into"
    type        = string
}

variable "tags" {
    description = "A map of tags to add to all resources"
    type        = map(string)
}