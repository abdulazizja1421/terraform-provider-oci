variable "oci_tenancy" {
    type = string
    description = "OCI tenancy identifier"
}

variable "oci_user" {
    type = string
    description = "OCI user identifier"
}

variable "oci_fingerprint" {
    type = string
    description = "OCI fingerprint for the key pair"
}

variable "private_key_path" {
    type = string
    description = "OCI key pair"
}

variable "ssh_public_key" {
        type = string
        description = "OCI Public key pair"
        default = "C:/Users/Ziad/.oci/KSA/z.alrefai@clever.sa_2023-08-06T12_30_22.326Z_public.pem"
}

variable "oci_region" {
    type = string
    description = "OCI region"
    default = "me-jeddah-1"
}

variable "oci_root_compartment" {
    type = string
    description = "OCI root compartment"
}

