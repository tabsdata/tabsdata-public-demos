#!/bin/bash
#
# Copyright 2025. Tabs Data Inc.
#

export TD_SERVER=${TD_SERVER:=localhost:2457}
export TD_USER=${TD_USER:=admin}
export TD_PASSWORD=${TD_PASSWORD:=tabsdata}
export TD_ROLE=${TD_ROLE:=sys_admin}
export TDX=$PWD


#input your AWS credentials below
export AWS_ACCESS_KEY_ID=?
export AWS_SECRET_ACCESS_KEY=?
export AWS_REGION=?
export AWS_BUCKET=?


#input your databricks credentials below
export DATABRICKS_HOST_URL=?
export DATABRICKS_TOKEN=?
export VOLUME=?
export CATALOG=?
export SCHEMA=?
export WAREHOUSE=?




