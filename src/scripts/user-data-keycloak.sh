#!/bin/bash

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo groupadd docker
sudo usermod -aG docker outscale


cd /opt/
mkdir keycloak
cd keycloak
docker run -p 8080:8080 -e KC_BOOTSTRAP_ADMIN_USERNAME=UsernameToChange -e KC_BOOTSTRAP_ADMIN_PASSWORD=PasswordToChange quay.io/keycloak/keycloak:26.3.3 start-dev
# For production, see https://www.keycloak.org/getting-started/getting-started-docker

