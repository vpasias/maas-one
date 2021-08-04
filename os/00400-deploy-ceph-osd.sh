#!/bin/bash
juju deploy --config config/ceph-osd.yaml -n 3 --to 6,7,8 cs:ceph-osd ceph-osd
