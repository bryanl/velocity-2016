resource "digitalocean_floating_ip" "lb" {
  droplet_id = "${element(digitalocean_droplet.lb.*.id, 0)}"
  region = "${var.region}"
}

resource "digitalocean_record" "lb" {
  domain = "${var.lb_domain}"
  type = "A"
  name = "*.${var.lb_subdomain}"
  value = "${digitalocean_floating_ip.lb.ip_address}"
}