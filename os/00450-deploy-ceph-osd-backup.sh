#!/bin/bash
#juju deploy --config config/ceph-osd-backup.yaml -n 3 --to 9,10,11 cs:ceph-osd ceph-osd-backup
juju deploy --config config/ceph-osd-backup.yaml -n 3 --to 9,10,11 cs:~openstack-charmers-next/ceph-osd ceph-osd-backup
