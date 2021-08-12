#!/bin/bash
#juju deploy --config config/keystone.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:keystone keystone
#juju deploy --config config/keystone.yaml cs:hacluster keystone-hacluster
juju deploy --config config/keystone.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:~openstack-charmers-next/keystone keystone
juju deploy --config config/keystone.yaml cs:~openstack-charmers-next/hacluster keystone-hacluster
juju add-relation keystone:ha keystone-hacluster:ha
#
juju add-relation keystone:shared-db mysql:shared-db
