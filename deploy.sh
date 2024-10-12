# script to deploy the app with a VPN container
# in case compose is not the way to go

#!/usr/bin/env bash
. .env

VPN_CONTAINER_NAME="vpn"
VPN_CONTAINER_IMAGE="qmcgaw/gluetun"

APP_CONTAINER_NAME="app"
APP_IMAGE_NAME="go-scraper"

# start VPN
echo "Starting VPN container ..."
docker container rm -f ${VPN_CONTAINER_NAME} || true
docker run --rm -d\
  -e VPN_SERVICE_PROVIDER=${VPN_SERVICE_PROVIDER}\
  -e OPENVPN_USER=${OPENVPN_USER}\
  -e OPENVPN_PASSWORD=${OPENVPN_PASSWORD}\
  -e SERVER_COUNTRIES=${VPN_SERVER_COUNTRIES}\
  --cap-add NET_ADMIN\
  --entrypoint "/gluetun-entrypoint"\
  --name ${VPN_CONTAINER_NAME}\
  ${VPN_CONTAINER_IMAGE}

# wait for VPN healthcheck
echo "Waiting for VPN to be healthy ..."
while [ "`docker inspect -f {{.State.Health.Status}} ${VPN_CONTAINER_NAME}`" != "healthy" ]; do sleep 2; done

# build & run scraper
echo "Building & Running app ..."
docker build -t ${APP_IMAGE_NAME} .

echo "Starting app container ..."
docker container rm -f ${APP_CONTAINER_NAME} || true
docker run --rm\
  --network=container:${VPN_CONTAINER_NAME}\
  --name ${APP_CONTAINER_NAME}\
  ${APP_IMAGE_NAME}