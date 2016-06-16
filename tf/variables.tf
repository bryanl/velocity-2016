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

variable "caddy_url" {
  default = "https://caddyserver.com/download/build?os=linux&arch=amd64&features="
}