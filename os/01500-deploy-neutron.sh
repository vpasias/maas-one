#!/bin/bash
juju deploy --config config/neutron.yaml -n 3 --to 0,1,2 cs:neutron-gateway neutron-gateway
juju deploy --config config/neutron.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:neutron-api neutron-api
juju deploy cs:neutron-openvswitch neutron-openvswitch
#
juju deploy --config config/neutron.yaml cs:hacluster neutron-hacluster
juju add-relation neutron-api:ha neutron-hacluster:ha
#
juju add-relation neutron-gateway:quantum-network-service nova-cloud-controller:quantum-network-service
juju add-relation neutron-gateway:amqp rabbitmq-server:amqp
#
juju add-relation neutron-api:shared-db mysql:shared-db
juju add-relation neutron-api:identity-service keystone:identity-service
juju add-relation neutron-api:amqp rabbitmq-server:amqp
#
juju add-relation neutron-api:neutron-plugin-api neutron-gateway:neutron-plugin-api
juju add-relation neutron-api:neutron-plugin-api neutron-openvswitch:neutron-plugin-api
juju add-relation neutron-api:neutron-api nova-cloud-controller:neutron-api
#
juju add-relation neutron-openvswitch:amqp rabbitmq-server:amqp
juju add-relation neutron-openvswitch:neutron-plugin nova-compute:neutron-plugin
