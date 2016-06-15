variable "hosts" {}
variable "count" {}
variable "private_key" {}
variable "user" {}
variable "member_ips" {}
variable "weave_encryption" {}

resource "null_resource" "bootstrap" {
  count = "${var.count}"
  connection {
    host = "${element(split(",", var.hosts), count.index)}"
    type = "ssh"
    key_file = "${var.private_key}"
    user = "${var.user}"
  }

  provisioner "file" {
    source = "${path.module}/sysctl.conf"
    destination = "/etc/sysctl.conf"
  }

  provisioner "file" {
    source = "${path.module}/provision.sh"
    destination = "/usr/local/bin/provision.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/terraform",
      "echo '${var.weave_encryption}' > /etc/terraform/weave_encryption",
      "echo '${var.member_ips}' > /etc/terraform/member_ips",
      "chmod +x /usr/local/bin/provision.sh",
      "/usr/local/bin/provision.sh 2>&1 > /tmp/provision.out"
    ]
  }
}