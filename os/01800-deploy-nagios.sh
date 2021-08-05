#!/bin/bash
juju deploy --config config/nagios.yaml -n 1 --to 12 cs:nagios nagios
juju deploy --config config/nagios.yaml cs:ntp nagios-ntp
juju deploy cs:nrpe nrpe
juju add-relation nagios:juju-info nagios-ntp:juju-info
juju add-relation nagios:monitors nrpe:monitors
juju add-relation nrpe:nrpe-external-master ceph-mon:nrpe-external-master
juju add-relation nrpe:nrpe-external-master ceph-mon-backup:nrpe-external-master
juju add-relation nrpe:nrpe-external-master ceph-osd:nrpe-external-master
juju add-relation nrpe:nrpe-external-master ceph-osd-backup:nrpe-external-master
juju add-relation nrpe:nrpe-external-master ceph-radosgw:nrpe-external-master
juju add-relation nrpe:nrpe-external-master ceph-radosgw-hacluster:nrpe-external-master
juju add-relation nrpe:nrpe-external-master cinder:nrpe-external-master
juju add-relation nrpe:nrpe-external-master cinder-hacluster:nrpe-external-master
juju add-relation nrpe:nrpe-external-master glance:nrpe-external-master
juju add-relation nrpe:nrpe-external-master glance-hacluster:nrpe-external-master
juju add-relation nrpe:nrpe-external-master keystone:nrpe-external-master
juju add-relation nrpe:nrpe-external-master keystone-hacluster:nrpe-external-master
juju add-relation nrpe:nrpe-external-master memcached:nrpe-external-master
juju add-relation nrpe:nrpe-external-master mysql:nrpe-external-master
juju add-relation nrpe:nrpe-external-master mysql-hacluster:nrpe-external-master
juju add-relation nrpe:nrpe-external-master ncc-hacluster:nrpe-external-master
juju add-relation nrpe:nrpe-external-master neutron-api:nrpe-external-master
juju add-relation nrpe:nrpe-external-master neutron-gateway:nrpe-external-master
juju add-relation nrpe:nrpe-external-master neutron-hacluster:nrpe-external-master
juju add-relation nrpe:nrpe-external-master nova-cloud-controller:nrpe-external-master
juju add-relation nrpe:nrpe-external-master nova-compute:nrpe-external-master
juju add-relation nrpe:nrpe-external-master ntp:nrpe-external-master
juju add-relation nrpe:nrpe-external-master openstack-dashboard:nrpe-external-master
juju add-relation nrpe:nrpe-external-master openstack-dashboard-hacluster:nrpe-external-master
juju add-relation nrpe:nrpe-external-master rabbitmq-server:nrpe-external-master
