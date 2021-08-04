#!/bin/bash
juju deploy --config config/openstack-dashboard.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:openstack-dashboard openstack-dashboard
juju deploy --config config/openstack-dashboard.yaml cs:hacluster openstack-dashboard-hacluster
juju add-relation openstack-dashboard:ha openstack-dashboard-hacluster:ha
#
juju add-relation openstack-dashboard:shared-db mysql:shared-db
juju add-relation openstack-dashboard:identity-service keystone:identity-service
