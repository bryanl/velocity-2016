variable "ssh_fingerprint" {}

variable "do_token" {}

variable "region" {}

variable "image" {
  default = "ubuntu-16-04-x64"
}

variable "etcd_size" {
  default = "2gb"
}

variable "etcd_count" {
  default = "3"
}

variable "master_size" {
  default = "16gb"
}

variable "master_count" {
  default = "1"
}

variable "node_size" {
  default = "16gb"
}

variable "node_count" {
  default = "3"
}

variable "lb_count" {
  default = "1"
}

variable "lb_size" {
  default = "4gb"
}

variable "frontend_count" {
  default = "1"
}

variable "frontend_size" {
  default = "4gb"
}

variable "user" {
  default = "root"
}

variable "private_key" {}

variable "weave_encryption" {}

variable "cert_organization" {
  default = "DigitalOcean Kubernetes"
}

variable "cert_validity_period_hours" {
  # one year
  default = 8760
}

variable "lb_domain" {}

variable "lb_subdomain" {}

variable "traefik_kubernetes_token" {}

variable "traefik_kubernetes_cacert" {}

variable "droplet_user_data" {
  default = <<EOT
#cloud-config
packages:
  - python
EOT
}