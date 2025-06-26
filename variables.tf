variable "resource_name_prefix" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "kb_config" {
  type = list(object({
    kb_name                = string
    source_bucket_name     = string
    source_bucket_prefixes = optional(list(string))
  }))
  validation {
    condition = alltrue([
      for config in var.kb_config : can(regex("^[A-Za-z0-9_-]{1,50}$", config.kb_name))
    ])
    error_message = "Valid characters for kb_name are a-z, A-Z, 0-9, _ (underscore) and - (hyphen). The name can have up to 50 characters."
  }
}

variable "rds_config" {
  type = object({
    vpc_id                   = string
    subnet_ids               = list(string)
    master_username          = optional(string, "db_user")
    max_capacity             = optional(number, 1.0)
    min_capacity             = optional(number, 0.0)
    seconds_until_auto_pause = optional(number, 900)
  })
}

variable "embedding_config" {
  type = object({
    model_id   = string
    dimensions = number
  })
  default = {
    model_id   = "amazon.titan-embed-text-v2:0"
    dimensions = 1024
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
