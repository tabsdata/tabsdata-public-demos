#!/bin/bash
#
# Copyright 2025. Tabs Data Inc.
#

export TD_SERVER=${TD_SERVER:=localhost:2457}
export TD_USER=${TD_USER:=admin}
export TD_PASSWORD=${TD_PASSWORD:=tabsdata}
export TD_ROLE=${TD_ROLE:=sys_admin}
export TD_INSTANCE_NAME=${TD_INSTANCE_NAME:=mindbody}
export TDX=$PWD

# PostgreSQL (Docker)
export PG_HOST=localhost
export PG_PORT=5432
export PG_DATABASE=mindbody
export PG_USER=postgres
export PG_PASSWORD=postgres


# Mindbody API credentials
export MINDBODY_API_KEY=?
export MINDBODY_STUDIO_ID=?
export MINDBODY_USERNAME=?
export MINDBODY_PASSWORD=?

