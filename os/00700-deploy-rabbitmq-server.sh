#!/bin/bash
# juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 cs:rabbitmq-server rabbitmq-server
juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 cs:~openstack-charmers-next/rabbitmq-server rabbitmq-server
