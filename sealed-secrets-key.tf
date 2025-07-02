locals {
  tls_crt = file("C:/Users/han16/new-sealed-secrets-key.pub")
  tls_key = file("C:/Users/han16/new-sealed-secrets-key.pem")
}

resource "kubernetes_secret" "sealed_secrets_key" {
  metadata {
    name      = "sealed-secrets-key"
    namespace = "kube-system"
    labels = {
      "sealedsecrets.bitnami.com/sealed-secrets-key" = "active"
    }
  }
  type = "kubernetes.io/tls"
  data = {
    "tls.crt" = local.tls_crt
    "tls.key" = local.tls_key
  }
}
