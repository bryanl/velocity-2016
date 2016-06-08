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

variable "user" {
  default = "root"
}

variable "private_key" {}