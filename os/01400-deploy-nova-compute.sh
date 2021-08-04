#!/bin/bash
juju deploy --config config/nova-compute.yaml -n 3 --to 3,4,5 cs:nova-compute nova-compute
#
juju add-relation nova-compute:cloud-compute nova-cloud-controller:cloud-compute
juju add-relation nova-compute:amqp rabbitmq-server:amqp
juju add-relation nova-compute:image-service glance:image-service
juju add-relation nova-compute:ceph ceph-mon:client
juju add-relation nova-compute:ceph-access cinder-ceph:ceph-access
