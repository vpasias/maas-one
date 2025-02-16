#!/bin/bash
# For ubuntu 18.04 deployment
juju bootstrap --bootstrap-series=bionic --bootstrap-constraints tags=juju maas-one maas-one
#juju bootstrap --bootstrap-series=bionic --bootstrap-constraints tags=juju --bootstrap-constraints mem=4096 maas-one maas-one
juju add-model --config default-series=bionic openstack

# For ubuntu 20.04 deployment
#juju bootstrap --bootstrap-series=focal --bootstrap-constraints tags=juju --bootstrap-constraints mem=4096 maas-one maas-one
#juju add-model --config default-series=bionic openstack
