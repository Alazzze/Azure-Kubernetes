provider "azurerm" {
  features {}
  subscription_id = "7fa7763f-4591-413f-b5db-4056e9ac64cb"
}

resource "azurerm_resource_group" "rg" {
  name     = "my-resource-group"
  location = "eastus"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "my-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "mysql_subnet" {
  name                 = "mysql-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "stastestakscluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "stastestakscluster"

  default_node_pool {
    name          = "default"
    node_count    = 1
    vm_size       = "Standard_B2ms"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.1.0.0/16"
    dns_service_ip = "10.1.0.10"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Development"
  }
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}

resource "azurerm_storage_account" "stasteststorage" {
  name                     = "stasteststorageacct"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "files_share" {
  name                 = "myfileshare"
  storage_account_name = azurerm_storage_account.stasteststorage.name
  quota                = 50
}

#  **If you need to deploy azurerm_mysql_flexible_server**

#resource "azurerm_mysql_flexible_server" "mysql" {
# name                = "stastestsqlserver"
# resource_group_name = azurerm_resource_group.rg.name
# location            = azurerm_resource_group.rg.location
# version             = "8.0.21"
# administrator_login = "stas"
# administrator_password = "Danceteam747!"

# storage {
#   size_gb = 20
# }

# sku_name = "B_Standard_B1ms"
 
}

resource "kubernetes_deployment" "wordpress" {
  metadata {
    name      = "wordpress"
    namespace = "default"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "wordpress"
      }
    }
    template {
      metadata {
        labels = {
          app = "wordpress"
        }
      }
      spec {
        container {
          name  = "wordpress"
          image = "wordpress:latest"
          port {
            container_port = 80
          }
          env {
            name  = "WORDPRESS_DB_HOST"
            value = "mysql-service"
          }
          env {
            name  = "WORDPRESS_DB_NAME"
            value = "wordpress"
          }
          env {
            name  = "WORDPRESS_DB_USER"
            value = "root"
          }
          env {
            name  = "WORDPRESS_DB_PASSWORD"
            value = "danceteam747"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "wordpress" {
  metadata {
    name      = "wordpress-service"
    namespace = "default"
  }
  spec {
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = 80
    }
    selector = {
      app = "wordpress"
    }
  }
}

resource "kubernetes_deployment" "phpmyadmin" {
  metadata {
    name      = "phpmyadmin"
    namespace = "default"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "phpmyadmin"
      }
    }
    template {
      metadata {
        labels = {
          app = "phpmyadmin"
        }
      }
      spec {
        container {
          name  = "phpmyadmin"
          image = "phpmyadmin/phpmyadmin:latest"
          port {
            container_port = 80
          }
          env {
            name  = "PMA_HOST"
            value = "mysql-service"
          }
          env {
            name  = "PMA_PORT"
            value = "3306"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "phpmyadmin" {
  metadata {
    name      = "phpmyadmin-service"
    namespace = "default"
  }
  spec {
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = 80
    }
    selector = {
      app = "phpmyadmin"
    }
  }
}

resource "kubernetes_deployment" "mysql" {
  metadata {
    name      = "mysql"
    namespace = "default"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "mysql"
      }
    }
    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }
      spec {
        container {
          name  = "mysql"
          image = "mysql:5.7"
          port {
            container_port = 3306
          }
          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = "danceteam747"
          }
          env {
            name  = "MYSQL_DATABASE"
            value = "wordpress"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mysql" {
  metadata {
    name      = "mysql-service"
    namespace = "default"
  }
  spec {
    type = "ClusterIP"
    port {
      port        = 3306
      target_port = 3306
    }
    selector = {
      app = "mysql"
    }
  }
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

# output "mysql_server_name" {
# value = azurerm_mysql_flexible_server.mysql.name
# }

output "storage_account_name" {
  value = azurerm_storage_account.stasteststorage.name
}

output "files_share_name" {
  value = azurerm_storage_share.files_share.name
}
