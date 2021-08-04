#!/bin/bash
juju deploy --config config/ntp.yaml cs:ntp ntp
juju add-relation ntp:juju-info ceph-osd:juju-info
juju add-relation ntp:juju-info ceph-osd-backup:juju-info
juju add-relation ntp:juju-info nova-compute:juju-info
juju add-relation ntp:juju-info neutron-gateway:juju-info
