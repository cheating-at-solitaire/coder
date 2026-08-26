output "coder_namespace" {
  value = kubernetes_namespace.coder.metadata[0].name
}

output "port_forward_command" {
  description = "Run this after apply to reach Coder locally, then browse to coder_access_url"
  value       = "kubectl port-forward -n ${var.coder_namespace} svc/coder 8080:80"
}
