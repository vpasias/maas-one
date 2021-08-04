#!/bin/bash
juju deploy --config config/cinder.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:cinder cinder
juju deploy --config config/cinder.yaml cs:hacluster cinder-hacluster
juju deploy cs:cinder-ceph cinder-ceph
juju add-relation cinder:ha cinder-hacluster:ha
#
juju add-relation cinder:shared-db mysql:shared-db
juju add-relation cinder:identity-service keystone:identity-service
juju add-relation cinder:amqp rabbitmq-server:amqp
#
juju add-relation cinder:image-service glance:image-service
#
juju add-relation cinder-ceph:storage-backend cinder:storage-backend
juju add-relation cinder-ceph:ceph ceph-mon:client
