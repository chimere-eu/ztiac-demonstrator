#!/bin/bash

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo groupadd docker
sudo usermod -aG docker outscale

cd /opt/
mkdir outline
cd outline
POSTGRES_PASSWORD='pass'
SECRET_KEY=$(openssl rand -hex 32)
UTILS_SECRET=$(openssl rand -hex 32)
cat <<EOF >docker.env
POSTGRES_USER=user
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_DB=outline
DATABASE_URL=postgres://user:${POSTGRES_PASSWORD}@postgres:5432/outline
NODE_ENV=production
URL=https://docs.ztiac-demonstrator.internal
COLLABORATION_URL=https://docs.ztiac-demonstrator.internal
SECRET_KEY=${SECRET_KEY}
UTILS_SECRET=${UTILS_SECRET}
REDIS_URL=redis://redis:6379
FORCE_HTTPS=false
PGSSLMODE=disable
EOF
cat <<EOF >docker-compose.yml
services:
  outline:
    image: docker.getoutline.com/outlinewiki/outline:latest
    env_file: ./docker.env
    ports:
      - "3000:3000"
    volumes:
      - storage-data:/var/lib/outline/data
    depends_on:
      - postgres
      - redis

  redis:
    image: redis
    env_file: ./docker.env
    expose:
      - "6379"
    volumes:
      - ./redis.conf:/redis.conf
    command: ["redis-server", "/redis.conf"]
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 30s
      retries: 3

  postgres:
    image: postgres
    env_file: ./docker.env
    environment:
      POSTGRES_USER: 'user'
      POSTGRES_PASSWORD: '${POSTGRES_PASSWORD}'
      POSTGRES_DB: 'outline'
    expose:
      - "5432"
    volumes:
      - database-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD", "pg_isready", "-d", "outline", "-U", "user"]
      interval: 30s
      timeout: 20s
      retries: 3

volumes:
  storage-data:
  database-data:
EOF

sleep 10
docker compose run --rm outline yarn db:create --env=production-ssl-disabled
sleep 10
docker compose run --rm outline yarn db:migrate --env=production-ssl-disabled
sleep 10
docker compose up -d