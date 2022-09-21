data "azurerm_client_config" "current" {}
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.82.0"
    }
  }
  # backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

locals {
  default_tags = {
    env        = var.env
    created-by = "terraform"
    product    = local.product
  }
  env     = var.env
  product = "vnetfagkveld2022"
}

# ----------------------------------------------------------------------------
# RG
# ----------------------------------------------------------------------------
resource "azurerm_resource_group" "this" {
  name     = "rg-${local.product}-${local.env}"
  location = var.location
  tags     = local.default_tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# ----------------------------------------------------------------------------
# Monitor
# ----------------------------------------------------------------------------
resource "azurerm_application_insights" "this" {
  name                = "ai-${local.product}-${local.env}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  application_type    = "web"
  # workspace_id        = azurerm_log_analytics_workspace.this.id
  tags = local.default_tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# ----------------------------------------------------------------------------
# Virtual Network
# ----------------------------------------------------------------------------
resource "azurerm_virtual_network" "this" {
  name                = "vnet-${local.product}-${var.env}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.vnet_address]
  tags                = local.default_tags
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_subnet" "inbound" {
  name                                           = "snet-inbound-${local.env}"
  resource_group_name                            = azurerm_resource_group.this.name
  virtual_network_name                           = azurerm_virtual_network.this.name
  address_prefixes                               = [var.subnet_address_inbound]
  enforce_private_link_endpoint_network_policies = true
  enforce_private_link_service_network_policies  = false
  service_endpoints = [
    "Microsoft.KeyVault",
    "Microsoft.Web",
    "Microsoft.ServiceBus",
    "Microsoft.AzureActiveDirectory",
  ]
}

resource "azurerm_subnet" "outbound" {
  name                                           = "snet-outbound-${local.env}"
  resource_group_name                            = azurerm_resource_group.this.name
  virtual_network_name                           = azurerm_virtual_network.this.name
  address_prefixes                               = [var.subnet_address_outbound]
  enforce_private_link_endpoint_network_policies = true
  enforce_private_link_service_network_policies  = false
  service_endpoints = [
    "Microsoft.KeyVault",
    "Microsoft.Web",
    "Microsoft.ServiceBus",
    "Microsoft.AzureActiveDirectory",
  ]
  delegation {
    name = "outbound_delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}

# ----------------------------------------------------------------------------
# DNS
# ----------------------------------------------------------------------------
resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.default_tags
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "vlink-${azurerm_virtual_network.this.name}"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = azurerm_virtual_network.this.id
  tags                  = local.default_tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# ----------------------------------------------------------------------------
# App Service Plan
# ----------------------------------------------------------------------------
resource "azurerm_app_service_plan" "this" {
  name                = "plan-${local.product}-${var.env}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  kind                = "elastic"
  sku {
    size = var.functions_plan_size
    tier = var.functions_plan_tier
  }
  maximum_elastic_worker_count = 1
  per_site_scaling             = true
  tags                         = local.default_tags
  lifecycle {
    ignore_changes = [tags, maximum_elastic_worker_count]
  }
}

resource "azurerm_storage_account" "this" {
  name                     = "st${local.product}${var.env}"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"
  allow_blob_public_access = false

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_function_app" "greenapi" {
  name                       = "func-greenapi-${local.env}"
  location                   = azurerm_resource_group.this.location
  resource_group_name        = azurerm_resource_group.this.name
  app_service_plan_id        = azurerm_app_service_plan.this.id
  version                    = "~4"
  https_only                 = true
  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key
  enable_builtin_logging     = false

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"       = ""
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.this.instrumentation_key
    "FUNCTIONS_WORKER_RUNTIME"       = "dotnet-isolated"
  }

  site_config {
    dotnet_framework_version         = "v6.0"
    scm_type        = "VSTSRM"
    ftps_state      = "FtpsOnly"
    app_scale_limit = 1
  }
  lifecycle {
    ignore_changes = [
      tags,
      app_settings,
    ]
  }
}

resource "azurerm_function_app" "solarcalc" {
  name                       = "func-solarcalc-${local.env}"
  location                   = azurerm_resource_group.this.location
  resource_group_name        = azurerm_resource_group.this.name
  app_service_plan_id        = azurerm_app_service_plan.this.id
  version                    = "~4"
  https_only                 = true
  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key
  enable_builtin_logging     = false

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"       = ""
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.this.instrumentation_key
    "FUNCTIONS_WORKER_RUNTIME"       = "dotnet-isolated"
  }

  site_config {
    dotnet_framework_version         = "v6.0"
    scm_type        = "VSTSRM"
    ftps_state      = "FtpsOnly"
    app_scale_limit = 1
  }
  lifecycle {
    ignore_changes = [
      tags,
      app_settings,
    ]
  }
}
