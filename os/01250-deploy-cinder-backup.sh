#!/bin/bash
juju deploy cs:~openstack-charmers/cinder-backup cinder-backup
#
juju add-relation cinder-backup:backup-backend cinder:backup-backend
juju add-relation cinder-backup:ceph ceph-mon-backup:client
