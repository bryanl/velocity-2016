#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ANSIBLE_DIR=$SCRIPT_DIR/..
TF_INVENTORY="/usr/local/bin/terraform-inventory"

TF_STATE=${SCRIPT_DIR}/../../tf/terraform.tfstate \
  ansible-playbook \
    --inventory-file=${TF_INVENTORY} \
      ${ANSIBLE_DIR}/site.yml $@
