provider "openstack" {
    user_name   = "<your username>"
    tenant_name = "<your tenant>"
    tenant_id   = "<your tenant_id>"
    password    = "<your password>"
    auth_url    = "https://<your URL>/:5000/v2.0"
}


variable "defaults" {
    description = "OpenStack Variables for Tenant"
    type = "map"
    default  {
        image_name      = "<image_name>"
        az_name         = "<availability_zone>"
        region          = "<region>"
        tenant_name     = "<tenant_name>"
        key_pair        = "<your_keypair>"
    }
}


resource "template_file" "bootstraplb-int" {
    template = "${file("bootstraplb.sh")}"
    vars {
        web1 = "${openstack_compute_instance_v2.web1.network.0.fixed_ip_v4}"
        web2 = "${openstack_compute_instance_v2.web2.network.0.fixed_ip_v4}"
    }
}

resource "openstack_compute_instance_v2" "lb1" {
  name = "lb1"
  image_name = "${var.defaults.image_name}"
  flavor_name = "m1.small"
  availability_zone = "${var.defaults.az_name}"
  key_pair = "your_keypair"
  security_groups = ["security_group"]
  network {
    name = "network_name"
  }
  user_data = "${element(template_file.bootstraplb-int.*.rendered, 1)}"
  lifecycle {
    create_before_destroy = true
  }
}


resource "openstack_compute_instance_v2" "web1" {
  name = "web1"
  image_name = "${var.defaults.image_name}"
  flavor_name = "m1.small"
  availability_zone = "${var.defaults.az_name}"
  key_pair = "your_keypair"
  security_groups = ["security_group"]
  network {
    name = "network_name"
  }
  user_data = "${file("bootstrapweb.sh")}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "openstack_compute_instance_v2" "web2" {
  name = "web2"
  image_name = "${var.defaults.image_name}"
  flavor_name = "m1.small"
  availability_zone = "${var.defaults.az_name}"
  key_pair = "your_keypair"
  security_groups = ["security_group"]
  network {
    name = "network_name"
  }
  user_data = "${file("bootstrapweb.sh")}"
  lifecycle {
    create_before_destroy = true
  }
}
