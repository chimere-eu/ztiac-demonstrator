variable "region" {
  default     = "cloudgouv-eu-west-1"
  type        = string
  description = "Outscale region on which resources are deployed"
}

variable "profile" {
  default     = "default"
  type        = string
  description = "Profile to use if you use a config file for the Outscale credentials"
}

variable "image_id" {
  type        = string
  description = "Id of the image to use for the VMs. E.g ami-0ab908cc"
}

variable "vm_type" {
  type        = string
  description = "The instance type to use for the VMs. E.g tinav5.c2r4p3"
}

variable "vm_type_apps" {
  type        = string
  description = "The instance type to use for the apps VMs. E.g tinav5.c2r4p3"
}

variable "allowed_cidr" {
  type        = list(string)
  description = "List of CIDR allowed to access the public IPs of VMs"
}

variable "public_key_path" {
  type        = string
  description = "Path to local ssh public key to use on created VMs"
}

variable "access_key_id" {
  default     = null
  type        = string
  description = "Outscale access key if you are not using a config file"
}

variable "secret_key_id" {
  default     = null
  type        = string
  description = "Outscale private key if you are not using a config file"
}