# Optional: streams workspace agent logs back through the Coder control plane.
# Remove this file if you don't need it.

resource "helm_release" "coder_logstream_kube" {
  name       = "coder-logstream-kube"
  repository = "https://helm.coder.com/logstream-kube"
  chart      = "coder-logstream-kube"
  namespace  = kubernetes_namespace.coder.metadata[0].name

  set {
    name  = "url"
    value = var.coder_access_url
  }

  depends_on = [helm_release.coder]
}
