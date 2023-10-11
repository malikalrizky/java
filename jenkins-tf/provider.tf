terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.23.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.11.0"
    }
  }
}

provider "kubernetes" { #windows
  config_path    = "~/.kube/config"
  config_context = "k3d-mycluster"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# provider "kubernetes" { #WSL
#   config_path    = "/mnt/c/Users/ACER/.kube/config"
#   config_context = "k3d-mycluster"
# }

# provider "helm" {
#   kubernetes {
#     config_path = "/mnt/c/Users/ACER/.kube/config"
#   }
# }
