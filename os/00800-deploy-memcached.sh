#!/bin/bash
# juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 cs:memcached memcached
juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 cs:~memcached-team/memcached memcached
