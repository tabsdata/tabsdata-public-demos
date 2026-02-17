#!/bin/bash
#
# Copyright 2025. Tabs Data Inc.
#

export MYSQL_HOST=localhost
export MYSQL_PORT=3307
export MYSQL_USER=root
export MYSQL_PASSWORD=mysql

export HASHICORP_HOST=localhost
export HASHICORP_PORT=8200
export HASHICORP_TOKEN=hashicorp-root-token


export RP_HOST_FUNCTION=localhost
export RP_PORT_KAFKA_FUNCTION=19092
export RP_HOST_DOCKER=host.docker.internal
export RP_PORT_KAFKA_DOCKER=29092

# Backward-compatible aliases for scripts that still read RP_HOST/RP_PORT_KAFKA
export RP_HOST=${RP_HOST_DOCKER}
export RP_PORT_KAFKA=${RP_PORT_KAFKA_DOCKER}
export RP_PORT_SCHEMA=18081
export RP_PORT_ADMIN=19644
export RP_ADMIN_USER=admin
export RP_ADMIN_PASS=secret

export TDS_HASHICORP_URL=http://${HASHICORP_HOST}:${HASHICORP_PORT}
export TDS_HASHICORP_TOKEN=${HASHICORP_TOKEN}
export TDS_HASHICORP_NAMESPACE=admin

export TD_SERVER=${TD_SERVER:=localhost:2457}
export TD_USER=${TD_USER:=admin}
export TD_PASSWORD=${TD_PASSWORD:=tabsdata}
export TD_ROLE=${TD_ROLE:=sys_admin}



