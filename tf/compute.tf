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
  count = "${var.etcd_count}"
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

resource "null_resource" "etcd-bootstrap" {
  count = "${var.etcd_count}"
  connection {
    host = "${element(digitalocean_droplet.etcd.*.ipv4_address, count.index)}"
    type = "ssh"
    key_file = "${var.private_key}"
    user = "${var.user}"
  }

  provisioner "file" {
    source = "scripts/provision.sh"
    destination = "/usr/local/bin/provision.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/terraform",
      "echo '${join(" ",digitalocean_droplet.etcd.*.ipv4_address_private)}' > /etc/terraform/etcd_ip",
      "echo '${join(" ",digitalocean_droplet.master.*.ipv4_address_private)}' > /etc/terraform/master_ip",
      "echo '${join(" ",digitalocean_droplet.node.*.ipv4_address_private)}' > /etc/terraform/node_ip",
      "chmod +x /usr/local/bin/provision.sh",
      "/usr/local/bin/provision.sh 2>&1 > /tmp/provision.out"
    ]
  }
}

resource "null_resource" "master-bootstrap" {
  count = "${var.master_count}"
  connection {
    host = "${element(digitalocean_droplet.master.*.ipv4_address, count.index)}"
    type = "ssh"
    key_file = "${var.private_key}"
    user = "${var.user}"
  }

  provisioner "file" {
    source = "scripts/provision.sh"
    destination = "/usr/local/bin/provision.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/terraform",
      "echo '${join(" ",digitalocean_droplet.etcd.*.ipv4_address_private)}' > /etc/terraform/etcd_ip",
      "echo '${join(" ",digitalocean_droplet.master.*.ipv4_address_private)}' > /etc/terraform/master_ip",
      "echo '${join(" ",digitalocean_droplet.node.*.ipv4_address_private)}' > /etc/terraform/node_ip",
      "chmod +x /usr/local/bin/provision.sh",
      "/usr/local/bin/provision.sh 2>&1 > /tmp/provision.out"
    ]
  }
}

resource "null_resource" "node-bootstrap" {
  count = "${var.node_count}"
  connection {
    host = "${element(digitalocean_droplet.node.*.ipv4_address, count.index)}"
    type = "ssh"
    key_file = "${var.private_key}"
    user = "${var.user}"
  }

  provisioner "file" {
    source = "scripts/provision.sh"
    destination = "/usr/local/bin/provision.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/terraform",
      "echo '${join(" ",digitalocean_droplet.etcd.*.ipv4_address_private)}' > /etc/terraform/etcd_ip",
      "echo '${join(" ",digitalocean_droplet.master.*.ipv4_address_private)}' > /etc/terraform/master_ip",
      "echo '${join(" ",digitalocean_droplet.node.*.ipv4_address_private)}' > /etc/terraform/node_ip",
      "chmod +x /usr/local/bin/provision.sh",
      "/usr/local/bin/provision.sh 2>&1 > /tmp/provision.out"
    ]
  }
}