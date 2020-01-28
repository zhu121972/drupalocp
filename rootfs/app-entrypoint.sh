#!/bin/bash -e

. /opt/bitnami/base/functions
. /opt/bitnami/base/helpers

print_welcome_page

if [[ "$1" == "nami" && "$2" == "start" ]] || [[ "$1" == "/init.sh" ]]; then
    . /apache-init.sh
    . /drupal-init.sh
    nami_initialize apache php mysql-client drupal
    info "Starting drupal... "
    . /post-init.sh
fi

exec tini -- "$@"
