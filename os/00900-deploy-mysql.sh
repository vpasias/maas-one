#!/bin/bash
# juju deploy --config config/mysql.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:percona-cluster mysql
juju deploy --config config/mysql.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:~openstack-charmers-next/percona-cluster mysql
# juju deploy --config config/mysql.yaml cs:hacluster mysql-hacluster
juju deploy --config config/mysql.yaml cs:~openstack-charmers-next/hacluster mysql-hacluster
juju add-relation mysql:ha mysql-hacluster:ha
