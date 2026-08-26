resource "kubernetes_namespace" "coder" {
  metadata {
    name = var.coder_namespace
  }
}
