#!/bin/bash
juju deploy --config config/ceph-radosgw.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:ceph-radosgw ceph-radosgw
juju deploy --config config/ceph-radosgw.yaml cs:hacluster ceph-radosgw-hacluster
juju add-relation ceph-radosgw:mon ceph-mon:radosgw
juju add-relation ceph-radosgw:ha ceph-radosgw-hacluster:ha
juju add-relation ceph-radosgw:identity-service keystone:identity-service
