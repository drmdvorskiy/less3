terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
  token     = var.yc_token
}

resource "yandex_compute_instance" "iscsi" {
  name = "iscsi"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  secondary_disk {
  disk_id = yandex_compute_disk.iscsi_disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
  }

  connection {
    type        = "ssh"
    user        = "centos"
    private_key = file("~/.ssh/id_rsa")
    host        = self.network_interface.0.nat_ip_address
  }
}

resource "yandex_compute_disk" "iscsi_disk" {
name     = "iscsi"
zone     = var.zone
size     = 1
}


resource "yandex_compute_instance" "pcm" {
  count = var.num
  name = "pcm-${count.index}"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
  }

  connection {
    type        = "ssh"
    user        = "centos"
    private_key = file("~/.ssh/id_rsa")
    host        = self.network_interface.0.nat_ip_address
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "internal_ip_address_pcm" {
  value = yandex_compute_instance.pcm.*.network_interface.0.ip_address
}

output "external_ip_address_pcm" {
  value = yandex_compute_instance.pcm.*.network_interface.0.nat_ip_address
}

output "internal_ip_address_iscsi" {
  value = yandex_compute_instance.iscsi.*.network_interface.0.ip_address
}

output "external_ip_address_iscsi" {
  value = yandex_compute_instance.iscsi.*.network_interface.0.nat_ip_address
}


output "internal_ip_address_pcm_0" {
  value = yandex_compute_instance.pcm[0].network_interface.0.ip_address
}
output "external_ip_address_pcm_0" {
  value = yandex_compute_instance.pcm[0].network_interface.0.nat_ip_address
}
output "internal_ip_address_pcm_1" {
  value = yandex_compute_instance.pcm[1].network_interface.0.ip_address
}
output "internal_ip_address_pcm_2" {
  value = yandex_compute_instance.pcm[2].network_interface.0.ip_address
}

output "hostname_pcm_0" {
  value = yandex_compute_instance.pcm[0].hostname
}
output "hostname_pcm_1" {
  value = yandex_compute_instance.pcm[1].hostname
}
output "hostname_pcm_2" {
  value = yandex_compute_instance.pcm[2].hostname
}
