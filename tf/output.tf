output "etcd_ip" {
  value = "${join(" ",digitalocean_droplet.etcd.*.ipv4_address_private)}"
}

output "master_ip" {
  value = "${join(" ",digitalocean_droplet.master.*.ipv4_address_private)}"
}

output "node_ip" {
  value = "${join(" ",digitalocean_droplet.node.*.ipv4_address_private)}"
}

output "lb_ip" {
  value = "${join(" ",digitalocean_droplet.lb.*.ipv4_address_private)}"
}

output "frontend_ip" {
  value = "${join(" ",digitalocean_droplet.frontend.*.ipv4_address_private)}"
}

output "fip_ip" {
  value = "${digitalocean_floating_ip.lb.ip_address}"
}