terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 0.13"
}

provider "scaleway" {
  zone = "fr-par-1"
  region = "fr-par"
}

resource "scaleway_instance_ip" "public_ip" {
}

resource "scaleway_vpc_private_network" "pn_priv" {
  name = "Nextcloud_EPSI"
  tags = ["Nextcloud"]
}

resource "scaleway_instance_volume" "server_volume" {
  name = "Data-Nextcloud-fr"
  type = "l_ssd"
  size_in_gb = 20
}

resource "scaleway_instance_server" "Grafana" {
  name = "Grafana"
  type = "GP1-XS"
  image = "ubuntu_focal"
  ip_id = scaleway_instance_ip.public_ip.id
  private_network {
    pn_id = scaleway_vpc_private_network.pn_priv.id
  }
  provisioner "remote-exec" {
    inline = ["sudo apt update", "sudo apt install python3 -y", "echo OK!"]
    connection {
      host = scaleway_instance_server.Grafana.public_ip
      type = "ssh"
      user = "root"
      private_key = file("/home/sysadmin/.ssh/id_rsa")
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${scaleway_instance_server.Grafana.public_ip},' --private-key /home/sysadmin/.ssh/id_rsa -e 'pub_key=/home/sysadmin/.ssh/id_rsa.pub}' grafana.yml"
  }
}

resource "scaleway_rdb_instance" "main" {
  name           = "Nextcloud-DB1"
  node_type      = "DB-GP-XS"
  engine         = "MySQL-8"
  is_ha_cluster  = true
  disable_backup = true
}
