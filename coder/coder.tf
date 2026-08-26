resource "kubernetes_secret" "coder_db_url" {
  metadata {
    name      = "coder-db-url"
    namespace = kubernetes_namespace.coder.metadata[0].name
  }
  data = {
    url = local.effective_postgres_url
  }
  type = "Opaque"

  depends_on = [kubernetes_service.postgres]
}

resource "helm_release" "coder" {
  name       = "coder"
  repository = "https://helm.coder.com/v2"
  chart      = "coder"
  namespace  = kubernetes_namespace.coder.metadata[0].name
  version    = var.coder_chart_version

  depends_on = [kubernetes_secret.coder_db_url]

  values = [
    yamlencode({
      coder = {
        env = concat(
          [
            {
              name = "CODER_PG_CONNECTION_URL"
              valueFrom = {
                secretKeyRef = {
                  name = kubernetes_secret.coder_db_url.metadata[0].name
                  key  = "url"
                }
              }
            },
            {
              name  = "CODER_ACCESS_URL"
              value = var.coder_access_url
            }
          ],
          var.coder_wildcard_access_url != "" ? [
            {
              name  = "CODER_WILDCARD_ACCESS_URL"
              value = var.coder_wildcard_access_url
            }
          ] : []
        )
        service = {
          type = var.coder_service_type
        }
      }
    })
  ]
}
