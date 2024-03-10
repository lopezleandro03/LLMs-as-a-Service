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

variable "project_id" {
    description = "The ID of the AI Project to deploy the AI Model into"
    type        = string
}

variable "model" {
    description = "The model to deploy"
    type        = object({
        id = string
        name = string
        marketplace_offer_id = string
        marketplace_plan_id  = string
        marketplace_publisher_id = string
    })
}

variable "tags" {
    description = "A map of tags to add to all resources"
    type        = map(string)
}