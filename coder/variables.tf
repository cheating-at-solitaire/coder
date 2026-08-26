variable "kube_config_path" {
  description = "Path to kubeconfig. If running Terraform inside WSL against a WSL-hosted cluster, ~/.kube/config is usually correct."
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Kube context to use. Leave blank to use current-context from kubeconfig."
  type        = string
  default     = ""
}

variable "coder_namespace" {
  description = "Namespace to deploy Coder (and its Postgres) into."
  type        = string
  default     = "coder"
}

variable "coder_chart_version" {
  description = "Version of the coder Helm chart to install. Check https://github.com/coder/coder/releases for current versions."
  type        = string
  default     = "2.18.0"
}

variable "coder_access_url" {
  description = "External URL Coder will be reachable at, e.g. http://localhost:8080 for a port-forwarded local setup."
  type        = string
  default     = "http://localhost:8080"
}

variable "coder_wildcard_access_url" {
  description = "Wildcard URL for workspace apps, e.g. *.coder.local.dev. Leave blank if not using subdomain app access."
  type        = string
  default     = ""
}

variable "deploy_inbuilt_postgres" {
  description = "If true, deploys a simple in-cluster Postgres for Coder. Set to false and supply postgres_url if you have your own database."
  type        = bool
  default     = true
}

variable "postgres_url" {
  description = "Postgres connection string for Coder's database. Ignored if deploy_inbuilt_postgres is true (an internal URL is generated instead)."
  type        = string
  default     = ""
  sensitive   = true
}

variable "postgres_password" {
  description = "Password for the in-cluster Postgres instance (only used if deploy_inbuilt_postgres is true)."
  type        = string
  default     = "coder"
  sensitive   = true
}

variable "coder_service_type" {
  description = "Kubernetes Service type for the Coder pod. ClusterIP + port-forward is simplest for local WSL dev."
  type        = string
  default     = "ClusterIP"
}
