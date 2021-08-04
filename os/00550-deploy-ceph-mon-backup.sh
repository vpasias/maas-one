#!/bin/bash
juju deploy --config config/ceph-mon-backup.yaml -n 3 --to lxd:0,lxd:1,lxd:2 cs:ceph-mon ceph-mon-backup
juju add-relation ceph-mon-backup:osd ceph-osd-backup:mon
