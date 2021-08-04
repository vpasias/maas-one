#!/bin/bash
juju deploy --config config/nova-cloud-controller.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:nova-cloud-controller nova-cloud-controller
juju deploy --config config/nova-cloud-controller.yaml cs:hacluster ncc-hacluster
juju add-relation nova-cloud-controller:ha ncc-hacluster:ha
#
juju add-relation nova-cloud-controller:shared-db mysql:shared-db
juju add-relation nova-cloud-controller:identity-service keystone:identity-service
juju add-relation nova-cloud-controller:amqp rabbitmq-server:amqp
#
juju add-relation nova-cloud-controller:memcache memcached:cache
juju add-relation nova-cloud-controller:image-service glance:image-service
juju add-relation nova-cloud-controller:cinder-volume-service cinder:cinder-volume-service
