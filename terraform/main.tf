provider "azurerm" {
  features {}
  use_msi = true
}

terraform {
  backend "azurerm" {
    resource_group_name   = "budget-demo"
    storage_account_name  = "bdgdemostrg"
    container_name        = "tflogs"
    key                   = "terraform.tfstate"
  }
}

locals {
  common_notification = {
    "enabled"       = true,
    "operator"      = "GreaterThan",
    "contactEmails" = var.default_values.contactEmails
  }
}

resource "azurerm_policy_definition" "budget" {
  name         = "Demo-Budget-Policy"
  display_name = "Demo-Budget-Policy"
  description  = "An example policy for deploying a default budget."

  policy_type = "Custom"
  mode        = "All"

  metadata = <<METADATA
{
  "version": "1.1.0",
  "category": "Budget",
  "source": "https://github.com/Azure/Enterprise-Scale/",
  "alzCloudEnvironments": ["AzureCloud", "AzureUSGovernment"]
}
METADATA

  parameters = <<PARAMETERS
{
  "amount": {
    "type": "String",
    "metadata": {
      "description": "The total amount of cost or usage to track with the budget"
    }
  },
  "timeGrain": {
    "type": "string",
    "defaultValue": var.default_values["timeGrain"],
    "allowedValues": ["Monthly", "Quarterly", "Annually", "BillingMonth", "BillingQuarter", "BillingAnnual"],
    "metadata": {
      "description": "The time covered by a budget. Tracking of the amount will be reset based on the time grain."
    }
  },
  "budgetName": {
    "type": "string",
    "defaultValue": "budget-set-by-policy",
    "metadata": {
      "description": "The name for the budget to be created"
    }
  },
  "firstThreshold": {
    "type": "String",
    "metadata": {
      "description": "Threshold value associated with a notification. Notification is sent when the cost exceeded the threshold. It is always percent and has to be between 0 and 1000."
    }
  },
  "secondThreshold": {
    "type": "String",
    "metadata": {
      "description": "Threshold value associated with a notification. Notification is sent when the cost exceeded the threshold. It is always percent and has to be between 0 and 1000."
    }
  },
  "startDate": {
    "type": "string",
    "defaultValue" : var.default_values["startDate"],
    "metadata": {
      "description": "The start date for the budget"
    }
  },
  "endDate": {
    "type": "string",
    "defaultValue" : var.default_values["endDate"],
    "metadata": {
      "description": "The end date for the budget"
    }
  },
  "contactEmails": {
    "type": "Array",
    "metadata": {
      "description": "The list of email addresses, in an array, to send the budget notification to when the threshold is exceeded."
    },
    "defaultValue": var.default_values["contactEmails"]
  },
  "contactRoles": {
    "type": "Array",
    "metadata": {
      "displayName": "contactRoles"
      "description": "The list of contact RBAC roles, in an array, to send the budget notification to when the threshold is exceeded."
    },
    "defaultValue": var.default_values["contactRoles"]
  },
  "contactGroups": {
    "type": "Array",
    "metadata": {
      "displayName": "contactGroups",
      "description": "The list of action groups, in an array, to send the budget notification to when the threshold is exceeded. It accepts an array of strings."
    },
    "defaultValue": var.default_values["contactGroups"]
  },
  "effect": {
    "type": "String",
    "defaultValue": var.default_values["effect"],
    "allowedValues": ["DeployIfNotExists", "AuditIfNotExists", "Disabled"],
    "metadata": {
      "description": "Enable or disable the execution of the policy"
    }
  }
}
PARAMETERS

  policy_rule = <<POLICY_RULE
{
  "if": {
    "allOf": [
      {
        "field": "type",
        "equals": "Microsoft.Resources/subscriptions"
      }
    ]
  },
  "then": {
    "effect": "[parameters('effect')]",
    "details": {
      "type": "Microsoft.Consumption/budgets",
      "deploymentScope": "subscription",
      "existenceScope": "subscription",
      "existenceCondition": {
        "allOf": [
          {
            "field": "Microsoft.Consumption/budgets/amount",
            "equals": "[parameters('amount')]"
          },
          {
            "field": "Microsoft.Consumption/budgets/timeGrain",
            "equals": "[parameters('timeGrain')]"
          },
          {
            "field": "Microsoft.Consumption/budgets/category",
            "equals": "Cost"
          }
        ]
      },
      "roleDefinitionIds": ["/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"],
      "deployment": {
        "location": "southcentralus",
        "properties": {
          "mode": "Incremental",
          "parameters": {
            "budgetName": {"value": "[parameters('budgetName')]"},
            "amount": {"value": "[parameters('amount')]"},
            "timeGrain": {"value": "[parameters('timeGrain')]"},
            "firstThreshold": {"value": "[parameters('firstThreshold')]"},
            "secondThreshold": {"value": "[parameters('secondThreshold')]"},
            "contactEmails": {"value": "[parameters('contactEmails')]"},
            "contactRoles": {"value": "[parameters('contactRoles')]"},
            "contactGroups": {"value": "[parameters('contactGroups')]"},
            "startDate": {"value": "[parameters('startDate')]"},
            "endDate": {"value":"[parameters('endDate')]"}
          },
          "template": {
            "$schema": "http://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json",
            "contentVersion": "1.0.0.0",
             "parameters": {
                        "amount": {
                                        "type": "String"
                                    },
                                    "budgetName": {
                                        "type": "String"
                                    },
                                    "contactEmails": {
                                        "type": "Array"
                                    },
                                    "contactGroups": {
                                        "type": "Array"
                                    },
                                    "contactRoles": {
                                        "type": "Array"
                                    },
                                    "endDate": {
                                        "type": "String"
                                    },
                                    "firstThreshold": {
                                        "type": "String"
                                    },
                                    "secondThreshold": {
                                        "type": "String"
                                    },
                                    "startDate": {
                                        "type": "String"
                                    },
                                    "timeGrain": {
                                        "type": "String"
                                    }
                                },
            "resources": [
              {
                "type": "Microsoft.Consumption/budgets",
                "apiVersion": "2021-10-01",
                "name": "[parameters('budgetName')]",
                "properties": {
                  "timePeriod": {
                    "startDate": "[parameters('startDate')]",
                    "endDate": "[parameters('endDate')]"
                  },
                  "timeGrain": "[parameters('timeGrain')]",
                  "amount": "[parameters('amount')]",
                  "category": "Cost",
                  "notifications": {
                    "NotificationForExceededBudget1": merge(local.common_notification, {
                      "threshold": "[parameters('firstThreshold')]"
                    },
                    "NotificationForExceededBudget2": merge(local.common_notification, {
                      "threshold": "[parameters('secondThreshold')]"
                    }
                  }
                }
              }
            ]
          }
        }
      }
    }
  }
}
POLICY_RULE
}

resource "azurerm_subscription_policy_assignment" "budgetassignment" {
  name                 = "budget-assignment"
  subscription_id = var.subscription_id
  policy_definition_id = azurerm_policy_definition.budget.id
  description          = "Deploy budgets to subscriptions"
  display_name         = "Deploy budgets to subscriptions"

  identity {
    type = "SystemAssigned"
  }
  location = "southcentralus"

  parameters = jsonencode({
    "budgetName"      = { "value" = var.budget_name },
    "amount"          = { "value" = var.amount },
    "timeGrain"       = { "value" = var.time_grain },
    "startDate"       = { "value" = var.default_values.startDate },
    "endDate"         = { "value" = var.default_values.endDate },
    "firstThreshold"  = { "value" = var.thresholds.firstThreshold },
    "secondThreshold" = { "value" = var.thresholds.secondThreshold },
    "contactEmails"   = { "value" = var.default_values.contactEmails },
    "contactRoles"    = { "value" = var.default_values.contactRoles },
    "contactGroups"   = { "value" = var.default_values.contactGroups },
    "effect"          = { "value" = var.default_values.effect }, # Add this line for the effect parameter
  })
}

resource "azurerm_role_assignment" "testuserid" {
  scope              = var.subscription_id
  role_definition_id = "${var.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
  principal_id       = azurerm_subscription_policy_assignment.budgetassignment.identity[0].principal_id

}
