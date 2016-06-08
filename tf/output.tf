output "etcd_ip" {
  value = "${join(" ",digitalocean_droplet.etcd.*.ipv4_address_private)}"
}

output "master_ip" {
  value = "${join(" ",digitalocean_droplet.master.*.ipv4_address_private)}"
}

output "node_ip" {
  value = "${join(" ",digitalocean_droplet.node.*.ipv4_address_private)}"
}
