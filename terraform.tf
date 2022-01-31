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

resource "scaleway_instance_ip" "ip2_public" {
}

#resource "scaleway_lb_ip" "ip" {
# reverse = "nextlcoud.is404notfound.fr"
# reverse = "grafana.is404notfound.fr"
#}

resource "scaleway_vpc_private_network" "pn02" {
  name = "Nextcloud_EPSI"
  tags = ["Nextcloud"]
}

#resource "scaleway_lb" "base"{
#  ip_id = scaleway_lb_ip.ip.id
#  zone = "fr-par-1"
#  type = "LB-S"
#  release_ip = true
#  private_network {
#    private_network_id = scaleway_vpc_private_network.pn_priv.id
#    static_config = ["172.16.0.2", "172.16.0.3"]
#  }
#}

#resource "scaleway_lb_backend" "backend_nextcloud" {
#  lb_id            = scaleway_lb.base.id
#  name             = "nextcloud"
#  forward_protocol = "http"
#  forward_port     = "80"
#}

#resource "scaleway_lb_backend" "backend_grafana" {
#  lb_id            = scaleway_lb.base.id
#  name             = "grafana"
#  forward_protocol = "http"
#  forward_port     = "3000"
#}

#resource "scaleway_lb_frontend" "frontend" {
#  lb_id        = scaleway_lb.base.id
#  backend_id   = scaleway_lb_backend.backend_grafana.id
#  name         = "frontend"
#  inbound_port = "80"
#}
#######################################
resource scaleway_vpc_public_gateway_dhcp main {
    subnet = "192.168.1.0/24"
}

resource scaleway_vpc_public_gateway_ip main {
}

resource scaleway_vpc_public_gateway main {
    name = "foobar"
    type = "VPC-GW-S"
    ip_id = scaleway_vpc_public_gateway_ip.main.id
}

resource scaleway_vpc_public_gateway_pat_rule main {
    gateway_id = scaleway_vpc_public_gateway.main.id
    private_ip = scaleway_vpc_public_gateway_dhcp.main.address
    private_port = scaleway_rdb_instance.Nextcloud-DB1.private_network.0.port
    public_port = 4258
    protocol = "both"
    depends_on = [scaleway_vpc_gateway_network.main, scaleway_vpc_private_network.pn02]
}

resource scaleway_vpc_gateway_network main {
    gateway_id = scaleway_vpc_public_gateway.main.id
    private_network_id = scaleway_vpc_private_network.pn02.id
    dhcp_id = scaleway_vpc_public_gateway_dhcp.main.id
    cleanup_dhcp = true
    enable_masquerade = true
    depends_on = [scaleway_vpc_public_gateway_ip.main, scaleway_vpc_private_network.pn02]
}
######################################
resource "scaleway_instance_volume" "nextcloud_volume" {
  name = "Data-Nextcloud-fr"
  type = "l_ssd"
  size_in_gb = 100
}

resource "scaleway_instance_server" "Grafana" {
  name = "Grafana"
  type = "GP1-XS"
  image = "ubuntu_focal"
  ip_id = scaleway_instance_ip.public_ip.id
  private_network {
    pn_id = scaleway_vpc_private_network.pn02.id
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

resource "scaleway_rdb_instance" "Nextcloud-DB1" {
  name           = "Nextcloud-DB1"
  node_type      = "DB-GP-XS"
  engine         = "MySQL-8"
  # is_ha_cluster  = true
  # disable_backup = true
  backup_schedule_frequency = 24
  backup_schedule_retention = 7
  private_network {
    ip_net = "192.168.1.254/24"
    pn_id = scaleway_vpc_private_network.pn02.id
  }
}

resource "scaleway_rdb_user" "nextcloud_user_db" {
  instance_id = scaleway_rdb_instance.Nextcloud-DB1.id
  name        = "DBAdmin"
  password    = "Epsi2022!DB"
  is_admin    = true
}

resource "scaleway_rdb_database" "nextcloud_db" {
  instance_id = scaleway_rdb_instance.Nextcloud-DB1.id
  name        = "nextcloud_db"
}

resource "scaleway_instance_server" "Nextcloud" {
  name = "Nextcloud"
  type = "GP1-XS"
  image = "ubuntu_focal"
  ip_id = scaleway_instance_ip.ip2_public.id
  private_network {
    pn_id = scaleway_vpc_private_network.pn02.id
  }
  provisioner "remote-exec" {
    inline = ["sudo apt update", "apt -y install python python-apt", "echo OK!"]
    connection {
      host = scaleway_instance_server.Nextcloud.public_ip
      type = "ssh"
      user = "root"
      private_key = file("/home/sysadmin/.ssh/id_rsa")
    }
  }
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${scaleway_instance_server.Nextcloud.public_ip},' --private-key /home/sysadmin/.ssh/id_rsa -e 'pub_key=/home/sysadmin/.ssh/id_rsa.pub}' nextcloud.yml"
  }

  additional_volume_ids = [ scaleway_instance_volume.nextcloud_volume.id ]
  root_volume {
    #Local storage de GP1-XS = 150Gb, retire 100 Gb pour le volume additionnel  l_ssd donc il reste 50Gb
    size_in_gb = 50
  }
}

