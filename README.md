# ZTIAC Demonstrator

The ZTIAC Demonstrator is an infrastructure-as-code project for deploying a multi-service environment using Terraform. It provisions and configures virtual machines and services such as Jitsi, Keycloak, Nextcloud, Outline, OpenBao, and Chimere Transfer Agent, with reverse proxies and network resources.

This demonstrator uses modules from the [ZTIAC project](https://github.com/chimere-eu/ztiac/).

## Repository Structure

- **src/**  
  Contains all Terraform configuration files, modules, and deployment scripts.
  - `network.tf`, `vms.tf`, `outscale.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars`  
    Core Terraform files for resource definitions and variables.
  - `.terraform/`  
    Terraform modules for each service (e.g., jitsi, keycloak, nextcloud, outline, openbao, reverse proxies, transfer agent).
  - `scripts/`  
    Shell scripts for provisioning services on VMs (e.g., user-data-jitsi.sh, `user-data-keycloak.sh`, etc.), Caddy reverse proxy configurations, and deployment config files.

- **docs/**  
  Documentation and architecture diagrams.

## Services Deployed

- **Jitsi Meet** – Video conferencing platform
- **Keycloak** – Identity and access management
- **Nextcloud** – File sharing and collaboration
- **Outline** – Wiki/documentation platform
- **OpenBao** – Secrets management
- **Chimere Transfer Agent** – Secure connector agent
- **Reverse Proxies** – Public and private Caddy proxies

## Getting Started

1. **Clone the repository**
   ```sh
   git clone https://github.com/chimere-eu/ztiac-demonstrator.git
   cd ztiac-demonstrator
   ```

2. **Configure variables**
   Edit terraform.tfvars to set your deployment parameters.

3. **Initialize Terraform**
   ```sh
   cd src
   terraform init
   ```

4. **Plan and apply the deployment**
   ```sh
   terraform plan
   terraform apply
   ```

5. **Service provisioning**
   VM user-data scripts in `src/scripts/` automatically install and configure each service.

## Documentation

- Architecture diagrams: architecture.excalidraw.svg
- Service-specific documentation: See module READMEs under modules
- Rapport de validation des performances, de la résilience et de la sécurité du démonstrateur ZTIAC : [RAPPORT.md](./RAPPORT.md)

---

For more details, refer to the documentation in the `github.com/chimere-eu/ztiac/` repository and the configuration scripts in `src/scripts/`.