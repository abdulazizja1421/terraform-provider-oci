// Copyright (c) 2017, 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Mozilla Public License v2.0

//variable "tenancy_ocid" {
//        type = string
//        description = "OCI tenancy identifier"
//        default = "ocid1.tenancy.oc1..aaaaaaaaagtl5ff4bqcsv3a2rckmoerxplwr6l5i5adslr4bdggbfbvfl5oa"
//}
//
//variable "user_ocid" {
//        type = string
//        description = "OCI user identifier"
//        default = "ocid1.user.oc1..aaaaaaaasspb77q2zkoymdnitpm5len4hym4zihwmdtcxvmhh35corv4haka"
//}
//
//variable "fingerprint" {
//        type = string
//        description = "OCI fingerprint for the key pair"
//        default = "e9:61:7f:8d:61:0a:30:d9:47:47:be:22:09:d4:14:95"
//}
//
//variable "private_key_path" {
//        type = string
//        description = "OCI Private key pair"
//        default = "C:/Users/Ziad/.oci/KSA/z.alrefai@clever.sa_2023-08-06T12_30_22.611Z.pem"
//}
//
//variable "ssh_public_key" {
//        type = string
//        description = "OCI Public key pair"
//        default = "C:/Users/Ziad/.oci/KSA/z.alrefai@clever.sa_2023-08-06T12_30_22.326Z_public.pem"
//}
//
//variable "compartment_ocid" {
//        type = string
//        description = "OCI root compartment"
//        default = "value"
//}
//
//variable "region" {
//        type = string
//        description = "OCI region"
//        default = "me-jeddah-1"
//}
provider "oci" {
        region           = "me-jeddah-1"
        tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaaagtl5ff4bqcsv3a2rckmoerxplwr6l5i5adslr4bdggbfbvfl5oa"
        user_ocid        = "ocid1.user.oc1..aaaaaaaasspb77q2zkoymdnitpm5len4hym4zihwmdtcxvmhh35corv4haka"
        fingerprint      = "e9:61:7f:8d:61:0a:30:d9:47:47:be:22:09:d4:14:95"
        private_key_path = "C:/Users/Ziad/.oci/KSA/z.alrefai@clever.sa_2023-08-06T12_30_22.611Z.pem"
}

variable "instance_shape" {
        default = "VM.Standard.A1.Flex" # Or VM.Standard.E2.1.Micro
}

variable "instance_ocpus" { default = 1 }

variable "instance_shape_config_memory_in_gbs" { default = 6 }

data "oci_identity_availability_domain" "ad" {
        compartment_id = "ocid1.tenancy.oc1..aaaaaaaaagtl5ff4bqcsv3a2rckmoerxplwr6l5i5adslr4bdggbfbvfl5oa"
        ad_number      = 1
}

resource "oci_identity_compartment" "union1-compartment" {
    # Required
    compartment_id = "ocid1.tenancy.oc1..aaaaaaaaagtl5ff4bqcsv3a2rckmoerxplwr6l5i5adslr4bdggbfbvfl5oa"
    description = "Compartment for Terraform resources."
    name = "union2"
    lifecycle {  prevent_destroy = true}
}

/* Network */

resource "oci_core_virtual_network" "Ziyad_vcn" {
  cidr_block     = "10.0.0.0/25"
  compartment_id = oci_identity_compartment.union1-compartment.id
  display_name   = "ZiyadVCN"
  dns_label      = "Ziyadvcn"
  lifecycle {  prevent_destroy = true}
}

resource "oci_core_subnet" "Ziyad_subnet" {
  cidr_block        = "10.0.0.0/27"
  display_name      = "ZiyadSubnet"
  dns_label         = "Ziyadsubnet"
  security_list_ids = [oci_core_security_list.Ziyad_security_list.id]
  compartment_id    = oci_identity_compartment.union1-compartment.id
  vcn_id            = oci_core_virtual_network.Ziyad_vcn.id
  route_table_id    = oci_core_route_table.Ziyad_route_table.id
  dhcp_options_id   = oci_core_virtual_network.Ziyad_vcn.default_dhcp_options_id
  lifecycle {  prevent_destroy = true}
}

resource "oci_core_internet_gateway" "Ziyad_internet_gateway" {
  compartment_id = oci_identity_compartment.union1-compartment.id
  display_name   = "ZiyadIG"
  vcn_id         = oci_core_virtual_network.Ziyad_vcn.id
  lifecycle {  prevent_destroy = true}
}

resource "oci_core_route_table" "Ziyad_route_table" {
  compartment_id = oci_identity_compartment.union1-compartment.id
  vcn_id         = oci_core_virtual_network.Ziyad_vcn.id
  display_name   = "ZiyadRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.Ziyad_internet_gateway.id
  }
  lifecycle {  prevent_destroy = true}
}

resource "oci_core_security_list" "Ziyad_security_list" {
  compartment_id = oci_identity_compartment.union1-compartment.id
  vcn_id         = oci_core_virtual_network.Ziyad_vcn.id
  display_name   = "ZiyadSecurityList"

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "22"
      min = "22"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "3000"
      min = "3000"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "3005"
      min = "3005"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "80"
      min = "80"
    }
  }
  lifecycle {  prevent_destroy = true}
}


/* Instances */

resource "oci_core_instance" "free_instance0" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = oci_identity_compartment.union1-compartment.id
  display_name        = "freeInstance0"
  shape               = var.instance_shape

  shape_config {
    ocpus = var.instance_ocpus
    memory_in_gbs = var.instance_shape_config_memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.Ziyad_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = false
    hostname_label   = "freeinstance0"
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.test_images.images[0], "id")
    boot_volume_size_in_gbs = "50"
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key) 
    #ssh_public_keys = file(var.ssh_public_keys)
    #ssh_public_keys = var.ssh_public_keys
  }
}

resource "oci_core_instance" "free_instance1" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = oci_identity_compartment.union1-compartment.id
  display_name        = "freeInstance1"
  shape               = var.instance_shape

  shape_config {
    ocpus = 1
    memory_in_gbs = 6
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.Ziyad_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "freeinstance1"
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.test_images.images[0], "id")
  }

  metadata = {
    ssh_authorized_keys = (var.ssh_public_key != "") ? var.ssh_public_key : tls_private_key.compute_ssh_key.public_key_openssh
  }
}

resource "tls_private_key" "compute_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "generated_private_key_pem" {
  value     = (var.ssh_public_key != "") ? var.ssh_public_key : tls_private_key.compute_ssh_key.private_key_pem
  sensitive = true
}

/* Load Balancer */

resource "oci_load_balancer_load_balancer" "free_load_balancer" {
  #Required
  compartment_id = oci_identity_compartment.union1-compartment.id
  display_name   = "alwaysFreeLoadBalancer"
  shape          = "flexible"
  shape_details {
    maximum_bandwidth_in_mbps = 10
    minimum_bandwidth_in_mbps = 10
  }

  subnet_ids = [
    oci_core_subnet.Ziyad_subnet.id,
  ]
}

resource "oci_load_balancer_backend_set" "free_load_balancer_backend_set" {
  name             = "lbBackendSet1"
  load_balancer_id = oci_load_balancer_load_balancer.free_load_balancer.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
  }

  session_persistence_configuration {
    cookie_name      = "lb-session1"
    disable_fallback = true
  }
}

resource "oci_load_balancer_backend" "free_load_balancer_test_backend0" {
  #Required
  backendset_name  = oci_load_balancer_backend_set.free_load_balancer_backend_set.name
  ip_address       = oci_core_instance.free_instance0.public_ip
  load_balancer_id = oci_load_balancer_load_balancer.free_load_balancer.id
  port             = "80"
}

resource "oci_load_balancer_backend" "free_load_balancer_test_backend1" {
  #Required
  backendset_name  = oci_load_balancer_backend_set.free_load_balancer_backend_set.name
  ip_address       = oci_core_instance.free_instance1.public_ip
  load_balancer_id = oci_load_balancer_load_balancer.free_load_balancer.id
  port             = "80"
}

resource "oci_load_balancer_hostname" "test_hostname1" {
  #Required
  hostname         = "app.free.com"
  load_balancer_id = oci_load_balancer_load_balancer.free_load_balancer.id
  name             = "hostname1"
}

resource "oci_load_balancer_listener" "load_balancer_listener0" {
  load_balancer_id         = oci_load_balancer_load_balancer.free_load_balancer.id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.free_load_balancer_backend_set.name
  hostname_names           = [oci_load_balancer_hostname.test_hostname1.name]
  port                     = 80
  protocol                 = "HTTP"
  rule_set_names           = [oci_load_balancer_rule_set.test_rule_set.name]

  connection_configuration {
    idle_timeout_in_seconds = "240"
  }
}

resource "oci_load_balancer_rule_set" "test_rule_set" {
  items {
    action = "ADD_HTTP_REQUEST_HEADER"
    header = "example_header_name"
    value  = "example_header_value"
  }

  items {
    action          = "CONTROL_ACCESS_USING_HTTP_METHODS"
    allowed_methods = ["GET", "POST"]
    status_code     = "405"
  }

  load_balancer_id = oci_load_balancer_load_balancer.free_load_balancer.id
  name             = "test_rule_set_name"
}

//resource "tls_private_key" "example" {
//  algorithm   = "RSA"
//  rsa_bits = 2048
//  //ecdsa_curve = "P384"
//}
//
//resource "tls_self_signed_cert" "example" {
//  key_algorithm   = "RSA"
//  private_key_pem = tls_private_key.example.private_key_pem
//
//  subject {
//    organization = "Oracle"
//    country = "US"
//    locality = "Austin"
//    province = "TX"
//  }
//
//  validity_period_hours = 8760 # 1 year
//
//  allowed_uses = [
//    "key_encipherment",
//    "digital_signature",
//    "server_auth",
//    "client_auth",
//    "cert_signing"
//]
//
//  is_ca_certificate = true//
//}
//
//resource "oci_load_balancer_certificate" "load_balancer_certificate" {
//  load_balancer_id   = oci_load_balancer_load_balancer.free_load_balancer.id
//  ca_certificate     = tls_self_signed_cert.example.cert_pem
//  certificate_name   = "certificate1"
//  private_key        = tls_private_key.example.private_key_pem
//  public_certificate = tls_self_signed_cert.example.cert_pem
//lifecycle {  create_before_destroy = true}
//}
//
resource "oci_load_balancer_listener" "load_balancer_listener1" {
  load_balancer_id         = oci_load_balancer_load_balancer.free_load_balancer.id
  name                     = "https"
  default_backend_set_name = oci_load_balancer_backend_set.free_load_balancer_backend_set.name
  port                     = 443
  protocol                 = "HTTP"

  //ssl_configuration {
  //  certificate_name        = oci_load_balancer_certificate.load_balancer_certificate.certificate_name
  //  verify_peer_certificate = false
  //}
}

output "lb_public_ip" {
  value = [oci_load_balancer_load_balancer.free_load_balancer.ip_address_details]
}

data "oci_core_vnic_attachments" "app_vnics" {
  compartment_id      = oci_identity_compartment.union1-compartment.id
  availability_domain = data.oci_identity_availability_domain.ad.name
  instance_id         = oci_core_instance.free_instance0.id
}

data "oci_core_vnic" "app_vnic" {
  vnic_id = data.oci_core_vnic_attachments.app_vnics.vnic_attachments[0]["vnic_id"]
}

# See https://docs.oracle.com/iaas/images/
data "oci_core_images" "test_images" {
  compartment_id           = oci_identity_compartment.union1-compartment.id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

output "app" {
  value = "http://${data.oci_core_vnic.app_vnic.public_ip_address}"
}

data "oci_database_autonomous_databases" "test_autonomous1_databases" {
  #Required
  compartment_id = oci_identity_compartment.union1-compartment.id

  #Optional
  db_workload  = "OLTP"
  is_free_tier = "true"
}

resource "oci_database_autonomous_database" "test_autonomous1_database" {
  #Required
  admin_password           = "Testalwaysfree1@"
  compartment_id           = oci_identity_compartment.union1-compartment.id
  cpu_core_count           = "1"
  data_storage_size_in_tbs = "1"
  db_name                  = "testadb1"

  #Optional
  db_workload  = "OLTP"
  display_name = "test_autonomous1_database"

  freeform_tags = {
    "Department" = "Finance"
  }

  is_auto_scaling_enabled = "false"
  license_model           = "LICENSE_INCLUDED"
  is_free_tier            = "true"
}