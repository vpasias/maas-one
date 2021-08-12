#!/bin/bash
juju deploy --config config/placement.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:~openstack-charmers-next/bionic/placement placement
juju deploy --config config/placement.yaml cs:~openstack-charmers-next/hacluster placement-hacluster
juju add-relation placement:ha placement-hacluster:ha
#
juju add-relation placement:placement nova-cloud-controller:placement
juju add-relation placement:shared-db mysql:shared-db
juju add-relation placement:identity-service keystone:identity-service
