resource "kubernetes_deployment" "nginx" {
  provider = kubernetes.eks
  metadata {
    name = "nginx-deployment"
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 3
    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}
