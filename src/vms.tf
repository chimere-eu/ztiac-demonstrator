resource "outscale_keypair" "my_keypair" {
  keypair_name = "bastion-example-keypair"
  public_key   = file(var.public_key_path)
}

module "bastion" {
  source             = "github.com/chimere-eu/ztiac/modules/outscale/compute"
  subnet_id          = module.net.public_subnets["public-0"].id
  security_group_ids = [outscale_security_group.bastion_sg.security_group_id]
  vm_type            = var.vm_type
  image_id           = var.image_id
  private_ip         = "10.1.0.5"
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  name               = "demonstrator-bastion"
  assign_public_ip   = true
}

module "transfer-agent-chimere" {
  source             = "github.com/chimere-eu/ztiac/modules/outscale/compute"
  subnet_id          = module.net.private_subnets["private-0"].id
  security_group_ids = [outscale_security_group.sg_ssh_bastion.security_group_id]
  vm_type            = var.vm_type
  image_id           = var.image_id
  private_ip         = "10.1.2.10"
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  name               = "demonstrator-ta-chimere"
  assign_public_ip   = false
  chimere = [
    {
      port        = 22
      vault_token = "<OpenBao token to replace>"
      secret_url  = "http://10.1.3.10:8200/v1/kv/data/secret1"
      urls        = ["chimere-connector.ssh"]
      name        = "chimere-connector-ssh"
      address     = "127.0.0.1"
    },
    {
      port        = 443
      vault_token = "<OpenBao token to replace>"
      secret_url  = "http://10.1.3.10:8200/v1/kv/data/secret1"
      urls        = ["auth.ztiac-demonstrator.internal"]
      name        = "auth"
      address     = "${module.private-reverse-proxy.private_ip}"
    },
    {
      port        = 443
      vault_token = "<OpenBao token to replace>"
      secret_url  = "http://10.1.3.10:8200/v1/kv/data/secret1"
      urls        = ["docs.ztiac-demonstrator.internal"]
      name        = "docs"
      address     = "${module.private-reverse-proxy.private_ip}"
    },
    {
      port        = 443
      vault_token = "<OpenBao token to replace>"
      secret_url  = "http://10.1.3.10:8200/v1/kv/data/secret1"
      urls        = ["drive.ztiac-demonstrator.internal"]
      name        = "drive"
      address     = "${module.private-reverse-proxy.private_ip}"
    }
  ]
}


module "private-reverse-proxy" {
  source             = "github.com/chimere-eu/ztiac/modules/outscale/compute"
  subnet_id          = module.net.private_subnets["private-1"].id
  security_group_ids = [outscale_security_group.sg_ssh_bastion.security_group_id, outscale_security_group.caddy_private_sg.security_group_id]
  vm_type            = var.vm_type
  image_id           = var.image_id
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  name               = "demonstrator-private-reverse-proxy"
  assign_public_ip   = false
  reverse_proxy = {
    caddyfile = file("./scripts/Caddyfile-private")
  }
}

module "public-reverse-proxy" {
  source             = "github.com/chimere-eu/ztiac/modules/outscale/compute"
  subnet_id          = module.net.public_subnets["public-1"].id
  security_group_ids = [outscale_security_group.sg_ssh_bastion.security_group_id, outscale_security_group.caddy_public_sg.security_group_id]
  vm_type            = var.vm_type
  image_id           = var.image_id
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  name               = "demonstrator-public-reverse-proxy"
  assign_public_ip   = true
  reverse_proxy = {
    caddyfile = file("./scripts/Caddyfile-public")
  }
}


module "openbao" {
  source             = "github.com/chimere-eu/ztiac/modules/outscale/compute"
  subnet_id          = module.net.private_subnets["private-1"].id
  security_group_ids = [outscale_security_group.sg_ssh_bastion.security_group_id, outscale_security_group.openbao_sg.security_group_id]
  vm_type            = var.vm_type
  image_id           = var.image_id
  private_ip         = "10.1.3.10"
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  name               = "demonstrator-openbao"
  assign_public_ip   = true
  user_data          = file("./scripts/config.yaml")
  user_data_type     = "cloud-config"
  block_device_mappings = [
    {
      device_name = "/dev/sda1"
      bsu = {
        volume_size           = 10
        volume_type           = "gp2"
        delete_on_vm_deletion = true
      }
    },
    {
      device_name = "/dev/sdb"
      bsu = {
        volume_size           = 15
        volume_type           = "gp2"
        delete_on_vm_deletion = true
      }
    }

  ]
}

#================================================#
# Apps
#================================================#

module "nextcloud" {
  source             = "github.com/chimere-eu/ztiac/modules/outscale/compute"
  subnet_id          = module.net.private_subnets["private-1"].id
  security_group_ids = [outscale_security_group.sg_ssh_bastion.security_group_id, outscale_security_group.sg_drive.security_group_id]
  vm_type            = var.vm_type_apps
  image_id           = var.image_id
  private_ip         = "10.1.3.11"
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  name               = "demonstrator-nextcloud"
  assign_public_ip   = false
  user_data          = file("scripts/user-data-nextcloud.sh")
  user_data_type     = "shell"
  block_device_mappings = [
    {
      device_name = "/dev/sda1"
      bsu = {
        volume_size           = 20
        volume_type           = "gp2"
        delete_on_vm_deletion = true
      }
    },
    {
      device_name = "/dev/sdb"
      bsu = {
        volume_size           = 50
        volume_type           = "gp2"
        delete_on_vm_deletion = true
      }
    }

  ]
}


module "outline" {
  source             = "github.com/chimere-eu/ztiac/modules/outscale/compute"
  subnet_id          = module.net.private_subnets["private-1"].id
  security_group_ids = [outscale_security_group.sg_ssh_bastion.security_group_id, outscale_security_group.sg_docs.security_group_id]
  vm_type            = var.vm_type_apps
  image_id           = var.image_id
  private_ip         = "10.1.3.12"
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  name               = "demonstrator-outline"
  assign_public_ip   = false
  user_data          = file("scripts/user-data-outline.sh")
  user_data_type     = "shell"
  block_device_mappings = [
    {
      device_name = "/dev/sda1"
      bsu = {
        volume_size           = 20
        volume_type           = "gp2"
        delete_on_vm_deletion = true
      }
    },
    {
      device_name = "/dev/sdb"
      bsu = {
        volume_size           = 50
        volume_type           = "gp2"
        delete_on_vm_deletion = true
      }
    }

  ]
}


module "keycloak" {
  source             = "github.com/chimere-eu/ztiac/modules/outscale/compute"
  subnet_id          = module.net.private_subnets["private-1"].id
  security_group_ids = [outscale_security_group.sg_ssh_bastion.security_group_id, outscale_security_group.sg_auth.security_group_id]
  vm_type            = var.vm_type_apps
  image_id           = var.image_id
  private_ip         = "10.1.3.13"
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  name               = "demonstrator-keycloak"
  assign_public_ip   = false
  user_data          = file("scripts/user-data-keycloak.sh")
  user_data_type     = "shell"
  block_device_mappings = [
    {
      device_name = "/dev/sda1"
      bsu = {
        volume_size           = 20
        volume_type           = "gp2"
        delete_on_vm_deletion = true
      }
    },
    {
      device_name = "/dev/sdb"
      bsu = {
        volume_size           = 50
        volume_type           = "gp2"
        delete_on_vm_deletion = true
      }
    }

  ]
}


module "jitsi" {
  source             = "github.com/chimere-eu/ztiac/modules/outscale/compute"
  subnet_id          = module.net.public_subnets["public-1"].id
  security_group_ids = [outscale_security_group.sg_ssh_bastion.security_group_id, outscale_security_group.sg_meet.security_group_id]
  vm_type            = var.vm_type_apps
  image_id           = var.image_id
  private_ip         = "10.1.1.14"
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  name               = "demonstrator-jitsi"
  assign_public_ip   = true
  user_data          = file("scripts/user-data-jitsi.sh")
  user_data_type     = "shell"
  block_device_mappings = [
    {
      device_name = "/dev/sda1"
      bsu = {
        volume_size           = 20
        volume_type           = "gp2"
        delete_on_vm_deletion = true
      }
    },
    {
      device_name = "/dev/sdb"
      bsu = {
        volume_size           = 50
        volume_type           = "gp2"
        delete_on_vm_deletion = true
      }
    }

  ]
}