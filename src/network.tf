module "net" {
  source                     = "github.com/chimere-eu/ztiac/modules/outscale/vpc"
  availability_zones         = ["cloudgouv-eu-west-1a", "cloudgouv-eu-west-1b", "cloudgouv-eu-west-1c"]
  region                     = var.region
  net_cidr                   = "10.1.0.0/16"
  public_subnets             = ["10.1.0.0/24", "10.1.1.0/24"]
  private_subnets            = ["10.1.2.0/24", "10.1.3.0/24"]
  shared_private_route_table = false
  shared_public_route_table  = false
  enable_nat_gateway         = true
  shared_nat                 = true
  name                       = "demonstrator-network"
}

resource "outscale_security_group" "bastion_sg" {
  description = "Demonstrator security group for bastion"
  net_id      = module.net.vpc_id
}

resource "outscale_security_group_rule" "bastion_sg_rule" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.bastion_sg.id
  rules {
    from_port_range = "22"
    to_port_range   = "22"
    ip_protocol     = "tcp"
    ip_ranges       = var.allowed_cidr
  }
}

resource "outscale_security_group" "sg_ssh_bastion" {
  description = "Demonstrator security group allow: ssh from bastion"
  net_id      = module.net.vpc_id
}

resource "outscale_security_group_rule" "sg_ssh_bastion_rule" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.sg_ssh_bastion.id
  rules {
    from_port_range = "22"
    to_port_range   = "22"
    ip_protocol     = "tcp"
    ip_ranges       = ["${module.bastion.private_ip}/32"]
  }
}


resource "outscale_security_group" "sg_meet" {
  description = "Demonstrator security group for meet"
  net_id      = module.net.vpc_id
}

resource "outscale_security_group_rule" "sg_meet_rule" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.sg_meet.id
  rules {
    from_port_range = "22"
    to_port_range   = "22"
    ip_protocol     = "tcp"
    ip_ranges       = ["${module.bastion.private_ip}/32"]
  }
  rules {
    from_port_range = "8443"
    to_port_range   = "8443"
    ip_protocol     = "tcp"
    ip_ranges       = ["${module.public-reverse-proxy.private_ip}/32"]
  }
}

resource "outscale_security_group" "sg_docs" {
  description = "Demonstrator security group for docs"
  net_id      = module.net.vpc_id
}

resource "outscale_security_group_rule" "sg_docs_rule" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.sg_docs.id
  rules {
    from_port_range = "22"
    to_port_range   = "22"
    ip_protocol     = "tcp"
    ip_ranges       = ["${module.bastion.private_ip}/32"]
  }
  rules {
    from_port_range = "3000"
    to_port_range   = "3000"
    ip_protocol     = "tcp"
    ip_ranges       = ["${module.private-reverse-proxy.private_ip}/32"]
  }
}

resource "outscale_security_group" "sg_drive" {
  description = "Demonstrator security group for drive"
  net_id      = module.net.vpc_id
}

resource "outscale_security_group_rule" "sg_drive_rule" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.sg_drive.id
  rules {
    from_port_range = "22"
    to_port_range   = "22"
    ip_protocol     = "tcp"
    ip_ranges       = ["${module.bastion.private_ip}/32"]
  }
  rules {
    from_port_range = "8080"
    to_port_range   = "8080"
    ip_protocol     = "tcp"
    ip_ranges       = ["${module.private-reverse-proxy.private_ip}/32"]
  }
}

resource "outscale_security_group" "sg_auth" {
  description = "Demonstrator security group for auth"
  net_id      = module.net.vpc_id
}

resource "outscale_security_group_rule" "sg_auth_rule" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.sg_auth.id
  rules {
    from_port_range = "22"
    to_port_range   = "22"
    ip_protocol     = "tcp"
    ip_ranges       = ["${module.bastion.private_ip}/32"]
  }
  rules {
    from_port_range = "8080"
    to_port_range   = "8080"
    ip_protocol     = "tcp"
    ip_ranges       = ["${module.private-reverse-proxy.private_ip}/32"]
  }
}

resource "outscale_security_group" "openbao_sg" {
  description = "Openbao security group"
  net_id      = module.net.vpc_id
}

resource "outscale_security_group_rule" "openbao_sg_rule" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.openbao_sg.id
  rules {
    from_port_range = "8200"
    to_port_range   = "8200"
    ip_protocol     = "tcp"
    ip_ranges       = var.allowed_cidr
  }
  rules {
    from_port_range = "8200"
    to_port_range   = "8200"
    ip_protocol     = "tcp"
    ip_ranges       = [ "${module.transfer-agent-chimere.private_ip}/32"]
  }
}

resource "outscale_security_group" "caddy_private_sg" {
  description = "Private caddy security group"
  net_id      = module.net.vpc_id
}

resource "outscale_security_group_rule" "caddy_private_sg_rule" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.caddy_private_sg.id
  rules {
    from_port_range = "443"
    to_port_range   = "443"
    ip_protocol     = "tcp"
    ip_ranges       = [ "${module.transfer-agent-chimere.private_ip}/32"]
  }
}

resource "outscale_security_group" "caddy_public_sg" {
  description = "Public caddy security group"
  net_id      = module.net.vpc_id
}

resource "outscale_security_group_rule" "caddy_public_sg_rule" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.caddy_public_sg.id
  rules {
    from_port_range = "443"
    to_port_range   = "443"
    ip_protocol     = "tcp"
    ip_ranges       = [ "0.0.0.0/0"]
  }
}