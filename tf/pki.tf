resource "tls_private_key" "lb" {
  algorithm = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "lb" {
  key_algorithm = "ECDSA"
  private_key_pem= "${tls_private_key.lb.private_key_pem}"

  subject {
    common_name = "*.${var.lb_subdomain}.${var.lb_domain}"
    organization = "${var.cert_organization}"
  }

  validity_period_hours = "${var.cert_validity_period_hours}"

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "null_resource" "configure_lb_cert" {
  count = "${var.lb_count}"
  connection {
    host = "${element(digitalocean_droplet.lb.*.ipv4_address, count.index)}"
    type = "ssh"
    key_file = "${var.private_key}"
    user = "${var.user}"
  }

}

