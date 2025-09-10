output "bastion_ip" {
  value = module.bastion.public_ip
}

output "caddy_ip" {
  value = module.public-reverse-proxy.public_ip
}