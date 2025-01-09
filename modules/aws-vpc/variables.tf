variable "region" {
  type        = string
  description = "(Required) AWS region"
}

variable "app-name" {
  type        = string
  description = "(Required) Application name for resources"
}

variable "availability_zones" {
  type = list(string)
   description = "(Required) Application name for resources"
}
