# Creating Multiple GCE using single resource block

resource "tls_private_key" "i27-ecommerce-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# save the private key to local firewall
resource "local_file" "i27-ecommerce-key-private" {
  content  = tls_private_key.i27-ecommerce-key.private_key_pem
  filename = "${path.module}/id_rsa"
}

# save the public key to local firewall
resource "local_file" "i27-ecommerce-key-public" {
  content  = tls_private_key.i27-ecommerce-key.public_key_openssh
  filename = "${path.module}/id_rsa.pub"
}

resource "google_compute_instance" "tf-vm-instance" {
    for_each = var.instances
    name = each.key
    machine_type = each.value.instance_type
    zone = each.value.zone
    boot_disk {
      initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20250425"
      size  = each.value.disk_size
      type  = "pd-standard"
    }

    }
    network_interface {
      network = google_compute_network.vpc_network.self_link
      subnetwork = each.value.subnet
      access_config {

      }
    }

    metadata = {
        ssh-keys = "${var.vm_user}:${tls_private_key.i27-ecommerce-key.public_key_openssh}"
    }

    connection {
       host = self.network_interface[0].access_config[0].nat_ip
       type = "ssh"
       user = var.vm_user
       private_key = tls_private_key.i27-ecommerce-key.private_key_pem
    }
    # provisioner 
    provisioner "file" {
     source = each.key == "ansible" ? "ansible.sh" :  "empty.sh"
     destination = each.key == "ansible" ? "/home/${var.vm_user}/ansible.sh" : "/home/${var.vm_user}/empty.sh"
    }

    # Provider block to execute the script on the remote machine
    provisioner "remote-exec" {
      inline = [
        each.key == "ansible" ? "chmod +x /home/${var.vm_user}/ansible.sh && /home/${var.vm_user}/ansible.sh" : "echo 'not an ansibke vm'"
      ]
    }

    # File provisioner to copy private key on all vm_user
    provisioner "file" {
      source = "${path.module}/id_rsa"
      destination = "/home/${var.vm_user}/ssh-key"
    }

}