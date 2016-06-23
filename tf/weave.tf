// module "etcd-bootstrap" {
//   source = "./member-bootstrap"

//   hosts = "${join(",", digitalocean_droplet.etcd.*.ipv4_address)}"
//   count = "${var.etcd_count}"
//   private_key = "${var.private_key}"
//   user = "${var.user}"
//   member_ips = "${join(" ", concat(digitalocean_droplet.etcd.*.ipv4_address_private, digitalocean_droplet.master.*.ipv4_address_private, digitalocean_droplet.node.*.ipv4_address_private, digitalocean_droplet.lb.*.ipv4_address_private, digitalocean_droplet.frontend.*.ipv4_address_private))}"
//   weave_encryption = "${var.weave_encryption}"
// }

// module "master-bootstrap" {
//   source = "./member-bootstrap"

//   hosts = "${join(",", digitalocean_droplet.master.*.ipv4_address)}"
//   count = "${var.master_count}"
//   private_key = "${var.private_key}"
//   user = "${var.user}"
//   member_ips = "${join(" ", concat(digitalocean_droplet.etcd.*.ipv4_address_private, digitalocean_droplet.master.*.ipv4_address_private, digitalocean_droplet.node.*.ipv4_address_private, digitalocean_droplet.lb.*.ipv4_address_private, digitalocean_droplet.frontend.*.ipv4_address_private))}"
//   weave_encryption = "${var.weave_encryption}"
// }

// module "node-bootstrap" {
//   source = "./member-bootstrap"

//   hosts = "${join(",", digitalocean_droplet.node.*.ipv4_address)}"
//   count = "${var.node_count}"
//   private_key = "${var.private_key}"
//   user = "${var.user}"
//   member_ips = "${join(" ", concat(digitalocean_droplet.etcd.*.ipv4_address_private, digitalocean_droplet.master.*.ipv4_address_private, digitalocean_droplet.node.*.ipv4_address_private, digitalocean_droplet.lb.*.ipv4_address_private, digitalocean_droplet.frontend.*.ipv4_address_private))}"
//   weave_encryption = "${var.weave_encryption}"
// }

// module "lb-bootstrap" {
//   source = "./member-bootstrap"

//   hosts = "${join(",", digitalocean_droplet.lb.*.ipv4_address)}"
//   count = "${var.lb_count}"
//   private_key = "${var.private_key}"
//   user = "${var.user}"
//   member_ips = "${join(" ", concat(digitalocean_droplet.etcd.*.ipv4_address_private, digitalocean_droplet.master.*.ipv4_address_private, digitalocean_droplet.node.*.ipv4_address_private, digitalocean_droplet.lb.*.ipv4_address_private, digitalocean_droplet.frontend.*.ipv4_address_private))}"
//   weave_encryption = "${var.weave_encryption}"
// }

// module "frontend-bootstrap" {
//   source = "./member-bootstrap"

//   hosts = "${join(",", digitalocean_droplet.frontend.*.ipv4_address)}"
//   count = "${var.lb_count}"
//   private_key = "${var.private_key}"
//   user = "${var.user}"
//   member_ips = "${join(" ", concat(digitalocean_droplet.etcd.*.ipv4_address_private, digitalocean_droplet.master.*.ipv4_address_private, digitalocean_droplet.node.*.ipv4_address_private, digitalocean_droplet.lb.*.ipv4_address_private, digitalocean_droplet.frontend.*.ipv4_address_private))}"
//   weave_encryption = "${var.weave_encryption}"
// }
