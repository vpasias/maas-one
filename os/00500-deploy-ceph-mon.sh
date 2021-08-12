#!/bin/bash
# juju deploy --config config/ceph-mon.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:ceph-mon ceph-mon
juju deploy --config config/ceph-mon.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:~openstack-charmers-next/ceph-mon ceph-mon
juju add-relation ceph-mon:osd ceph-osd:mon
