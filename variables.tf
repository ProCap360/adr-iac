variable "location" {
    type = string
    description = "The location of the terraform setup"
    default = "eastus"
}
variable "subdomain" {
    type = string
    description = "The location of the terraform setup"
    default = "adr-poc"
}
variable "vnet_address_space" {
    type = list(string)
    description = "virtual network"
    default = ["10.0.0.0/16"]
}
variable "subnet_address_space" {
    type = list(string)
    description = "subnet"
    default = ["10.0.0.0/24"]
}
variable "vm_size" {
    type = string
    description = "VM size for adr"
    default     = "Standard_B1ls" # 1 vCPU, 0.5 GiB
}