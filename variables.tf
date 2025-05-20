variable "vpc_name" {
    description = "Name of the VPC"
    type = string
}

# Subnet variables
variable "subnets" {
    description = "The details of the subnets to be created"
    type = list(object({
        name = string
        ip_cidr_range = string
        subnet_region = string
    }))
}

# Firewall name
variable "firewall_name" {
    description = "Name of the firewall"
    type = string
}

# Source Ranges 
variable "source_ranges" {
    type = list(string)
} 

variable "instances" {
   description = "Enter the details of vm"
   type = map(object({
    instance_type = string
    zone = string
    subnet = string
    disk_size = number



   })) 

}

# username  for d vm
variable "vm_user" {
  type = string
}
 
