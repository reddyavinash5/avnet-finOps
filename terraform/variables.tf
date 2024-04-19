variable "default_values" {
  description = "Default values for the budget policy parameters."
  type = map(string)
  default = {
    "startDate" = "2024-04-01",
    "endDate" = "2024-04-30",
    "contactRoles" = ["Owner", "Contributor"],
    "contactGroups" = ["budget-agroup"],
    "contactEmails" = ["avinash.reddy@insight.com"],
    "effect" = "DeployIfNotExists",
    "timeGrain" = "Monthly"
  }
}

variable "thresholds" {
  description = "The list of thresholds for the budget policy."
  type = map(string)
  default = [
    {
      "firstThreshold" = "90",
      "secondThreshold" = "110"
    }
  ]
  
}

variable "budget_name" {
  type    = string
  default = "Demo-Budget-Policy"
}

variable "amount" {
  type    = string
  default = "1000"
}

variable "time_grain" {
  type    = string
  default = "Monthly"
}

variable "management_group_id" {
  type = string
  default = ""
}

# variable "start_date" {
#   type = string
#   default = "2024-04-01"
# }

# variable "end_date" {
#   type = string
#   default = "2024-04-30"
# }

# variable "first_threshold" {
#   type    = string
#   default = "90"
# }

# variable "second_threshold" {
#   type    = string
#   default = "110"
# }

# variable "contact_emails" {
#   type    = list(string)
#   default = ["avinash.reddy@insight.com"]
# }


# variable "contact_roles" {
#   type        = list(string)
#   description = "The list of contact RBAC roles to send the budget notification to when the threshold is exceeded."
#   default     = ["Owner", "Contributor"]
# }

# variable "contact_groups" {
#   type        = list(string)
#   description = "The list of action groups to send the budget notification to when the threshold is exceeded."
#   default     = ["budget-agroup"]
# }

