#This variables are just secrets that I don't want to be exposed in GitHub:)
variable "gcp_project" {}
variable "gcp_region" {}
variable "rancher_api_url" {}
variable "rancher_access_key" {}
variable "rancher_secret_key" {}

# Config Variables
variable "nodes" {}
variable "machine_type" {}
variable "ssh_user" {}
variable "ssh_public_key" {}
variable "ssh_private_key" {}