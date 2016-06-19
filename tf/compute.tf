module "etcd-bootstrap" {
  source = "./member-bootstrap"

  hosts = "${join(",", digitalocean_droplet.etcd.*.ipv4_address)}"
  count = "${var.etcd_count}"
  private_key = "${var.private_key}"
  user = "${var.user}"
  member_ips = "${join(" ", concat(digitalocean_droplet.etcd.*.ipv4_address_private, digitalocean_droplet.master.*.ipv4_address_private, digitalocean_droplet.node.*.ipv4_address_private, digitalocean_droplet.lb.*.ipv4_address_private, digitalocean_droplet.frontend.*.ipv4_address_private))}"
  weave_encryption = "${var.weave_encryption}"
}

module "master-bootstrap" {
  source = "./member-bootstrap"

  hosts = "${join(",", digitalocean_droplet.master.*.ipv4_address)}"
  count = "${var.master_count}"
  private_key = "${var.private_key}"
  user = "${var.user}"
  member_ips = "${join(" ", concat(digitalocean_droplet.etcd.*.ipv4_address_private, digitalocean_droplet.master.*.ipv4_address_private, digitalocean_droplet.node.*.ipv4_address_private, digitalocean_droplet.lb.*.ipv4_address_private, digitalocean_droplet.frontend.*.ipv4_address_private))}"
  weave_encryption = "${var.weave_encryption}"
}

module "node-bootstrap" {
  source = "./member-bootstrap"

  hosts = "${join(",", digitalocean_droplet.node.*.ipv4_address)}"
  count = "${var.node_count}"
  private_key = "${var.private_key}"
  user = "${var.user}"
  member_ips = "${join(" ", concat(digitalocean_droplet.etcd.*.ipv4_address_private, digitalocean_droplet.master.*.ipv4_address_private, digitalocean_droplet.node.*.ipv4_address_private, digitalocean_droplet.lb.*.ipv4_address_private, digitalocean_droplet.frontend.*.ipv4_address_private))}"
  weave_encryption = "${var.weave_encryption}"
}

module "lb-bootstrap" {
  source = "./member-bootstrap"

  hosts = "${join(",", digitalocean_droplet.lb.*.ipv4_address)}"
  count = "${var.lb_count}"
  private_key = "${var.private_key}"
  user = "${var.user}"
  member_ips = "${join(" ", concat(digitalocean_droplet.etcd.*.ipv4_address_private, digitalocean_droplet.master.*.ipv4_address_private, digitalocean_droplet.node.*.ipv4_address_private, digitalocean_droplet.lb.*.ipv4_address_private, digitalocean_droplet.frontend.*.ipv4_address_private))}"
  weave_encryption = "${var.weave_encryption}"
}

module "frontend-bootstrap" {
  source = "./member-bootstrap"

  hosts = "${join(",", digitalocean_droplet.frontend.*.ipv4_address)}"
  count = "${var.lb_count}"
  private_key = "${var.private_key}"
  user = "${var.user}"
  member_ips = "${join(" ", concat(digitalocean_droplet.etcd.*.ipv4_address_private, digitalocean_droplet.master.*.ipv4_address_private, digitalocean_droplet.node.*.ipv4_address_private, digitalocean_droplet.lb.*.ipv4_address_private, digitalocean_droplet.frontend.*.ipv4_address_private))}"
  weave_encryption = "${var.weave_encryption}"
}

resource "digitalocean_droplet" "etcd" {
  count = "${var.etcd_count}"
  image = "${var.image}"
  name = "kube-etcd-${count.index+1}"
  region = "${var.region}"
  size = "${var.etcd_size}"
  private_networking = true

  ssh_keys = [
    "${var.ssh_fingerprint}",
  ]

  connection {
    user     = "${var.user}"
    type     = "ssh"
    key_file = "${var.private_key}"
    timeout  = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "id"
    ]
  }
}

resource "digitalocean_droplet" "master" {
  count = "${var.master_count}"
  image = "${var.image}"
  name = "kube-master-${count.index+1}"
  region = "${var.region}"
  size = "${var.master_size}"
  private_networking = true

  ssh_keys = [
    "${var.ssh_fingerprint}",
  ]

  connection {
    user     = "${var.user}"
    type     = "ssh"
    key_file = "${var.private_key}"
    timeout  = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "id"
    ]
  }
}

resource "digitalocean_droplet" "node" {
  count = "${var.node_count}"
  image = "${var.image}"
  name = "kube-node-${count.index+1}"
  region = "${var.region}"
  size = "${var.node_size}"
  private_networking = true

  ssh_keys = [
    "${var.ssh_fingerprint}",
  ]

  connection {
    user     = "${var.user}"
    type     = "ssh"
    key_file = "${var.private_key}"
    timeout  = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "id"
    ]
  }
}

resource "digitalocean_droplet" "lb" {
  count = "${var.lb_count}"
  image = "${var.image}"
  name = "kube-lb-${count.index+1}"
  region = "${var.region}"
  size = "${var.lb_size}"
  private_networking = true

  ssh_keys = [
    "${var.ssh_fingerprint}",
  ]

  connection {
    user     = "${var.user}"
    type     = "ssh"
    key_file = "${var.private_key}"
    timeout  = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "groupadd -r http",
      "mkdir -p /etc/caddy/ssl",
      "echo \"${tls_private_key.lb.private_key_pem}\" > /etc/caddy/ssl/site.key",
      "echo \"${tls_self_signed_cert.lb.cert_pem}\" > /etc/caddy/ssl/site.crt",
      "echo \"${template_file.caddyfile.rendered}\" > /etc/caddy/Caddyfile",
      "echo \"${template_file.caddy_service.rendered}\" > /etc/systemd/system/caddy.service"
    ]
  }
}

resource "template_file" "caddyfile" {
  template = "${file("${path.module}/Caddyfile")}"

  vars {
    backends = "${join(" ", formatlist("%s:80", digitalocean_droplet.node.*.ipv4_address_private))}"
  }
}

resource "template_file" "caddy_service" {
  template = "${file("${path.module}/caddy.service")}"
}

resource "digitalocean_droplet" "frontend" {
  count = "${var.frontend_count}"
  image = "${var.image}"
  name = "kube-frontend-${count.index+1}"
  region = "${var.region}"
  size = "${var.frontend_size}"
  private_networking = true

  ssh_keys = [
    "${var.ssh_fingerprint}",
  ]

  connection {
    user     = "${var.user}"
    type     = "ssh"
    key_file = "${var.private_key}"
    timeout  = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/traefik /var/run/secrets/kubernetes.io/serviceaccount",
      "cat <<EOF > /etc/traefik/traefik.toml",
      "${template_file.traefik.rendered}",
      "EOF",
      "echo \"${template_file.traefik_service.rendered}\" > /etc/systemd/system/traefik.service",
      "echo \"${template_file.traefik_kubernetes_token.rendered}\" > /var/run/secrets/kubernetes.io/serviceaccount/token",
      "echo \"${template_file.traefik_kubernetes_cacert.rendered}\" > /var/run/secrets/kubernetes.io/serviceaccount/ca.cert"
    ]
  }
}

resource "template_file" "traefik" {
  template = "${file("${path.module}/traefik.toml")}"
}
resource "template_file" "traefik_service" {
  template = "${file("${path.module}/traefik.service")}"
}
resource "template_file" "traefik_kubernetes_token" {
  template = "${var.traefik_kubernetes_token}"
}
resource "template_file" "traefik_kubernetes_cacert" {
  template = "${var.traefik_kubernetes_cacert}"
}

