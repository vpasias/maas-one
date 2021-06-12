#!/bin/sh -e

OS_VARIANT=ubuntu18.04
POOL=images  # Remove 'pool' option below if not using a libvirt storage pool.

# The Juju controller

VCPUS=2
RAM_SIZE_MB=8192
DISK_SIZE_GB_1=40
NAME=controller
MAC1="52:54:00:02:01:01"

virt-install \
  --os-variant $OS_VARIANT \
        --graphics vnc \
        --noautoconsole \
        --network network=internal,mac=$MAC1 \
        --name $NAME \
        --vcpus $VCPUS \
        --cpu host \
        --memory $RAM_SIZE_MB \
        --disk "$NAME"_1.img,size=$DISK_SIZE_GB_1,pool=$POOL,serial=workaround-lp-1876258-"$NAME"_1 \
        --boot network

# The usable MAAS nodes

VCPUS=8
RAM_SIZE_MB=32768
DISK_SIZE_GB_1=300
DISK_SIZE_GB_2=30
DISK_SIZE_GB_3=30

for NAME in node1 node2 node3 node4 node5; do

        case $NAME in
        node1)
          MAC1="52:54:00:03:01:01"
          MAC2="52:54:00:03:01:02"
          ;;
        node2)
          MAC1="52:54:00:03:02:01"
          MAC2="52:54:00:03:02:02"
          ;;
        node3)
          MAC1="52:54:00:03:03:01"
          MAC2="52:54:00:03:03:02"
          ;;
        node4)
          MAC1="52:54:00:03:04:01"
          MAC2="52:54:00:03:04:02"
        node5)
          MAC1="52:54:00:03:05:01"
          MAC2="52:54:00:03:05:02"          
          ;;
        esac

        virt-install \
          --os-variant $OS_VARIANT \
                --graphics vnc \
                --noautoconsole \
                --network network=internal,mac=$MAC1 \
                --network network=internal,mac=$MAC2 \
                --name $NAME \
                --vcpus $VCPUS \
                --cpu host \
                --memory $RAM_SIZE_MB \
                --disk "$NAME"_1.img,size=$DISK_SIZE_GB_1,pool=$POOL,serial=workaround-lp-1876258-"$NAME"_1 \
                --disk "$NAME"_2.img,size=$DISK_SIZE_GB_2,pool=$POOL,serial=workaround-lp-1876258-"$NAME"_2 \
                --disk "$NAME"_3.img,size=$DISK_SIZE_GB_3,pool=$POOL,serial=workaround-lp-1876258-"$NAME"_3 \
                --boot network

done
