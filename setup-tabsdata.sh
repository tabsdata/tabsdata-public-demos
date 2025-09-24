#!/bin/bash
#
# Copyright 2025. Tabs Data Inc.
#
#!/usr/bin/env bash
# set -Eeo pipefail
# trap 'echo "Error on line $LINENO while running: $BASH_COMMAND" >&2; exit 1' ERR


source ./source.sh


tdserver stop --instance s3_to_databricks
echo yes | tdserver delete --instance s3_to_databricks
tdserver start --instance s3_to_databricks

td login --server ${TD_SERVER} --user ${TD_USER} --password ${TD_PASSWORD} --role ${TD_ROLE}

td collection create --name workflow

echo
echo "Created 1 collection(s)"
echo


(cd functions;
td fn register --coll workflow --path 01_s3_pub.py::s3_pub
td fn register --coll workflow --path 02_trf.py::trf
td fn register --coll workflow --path 03_databricks_sub.py::databricks_sub
)



echo
echo "Registered the publisher functions"
echo









