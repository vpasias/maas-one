#!/bin/sh -e

OS_VARIANT=ubuntu18.04
#OS_VARIANT=ubuntu20.04
#POOL=images  # Remove 'pool' option below if not using a libvirt storage pool.

# The Juju controller

VCPUS=2
RAM_SIZE_MB=4096
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
        --disk "$NAME"_1.img,size=$DISK_SIZE_GB_1,serial=workaround-lp-1876258-"$NAME"_1 \
        --boot network

# The usable MAAS nodes

VCPUS=4
RAM_SIZE_MB=24576
DISK_SIZE_GB_1=120
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
          ;;
        node5)
          MAC1="52:54:00:03:05:01"
          MAC2="52:54:00:03:05:02"          
          ;;
        node6)
          MAC1="52:54:00:03:06:01"
          MAC2="52:54:00:03:06:02"
          ;;
        node7)
          MAC1="52:54:00:03:07:01"
          MAC2="52:54:00:03:07:02"
          ;;
        node8)
          MAC1="52:54:00:03:08:01"
          MAC2="52:54:00:03:08:02"
          ;;
        node9)
          MAC1="52:54:00:03:09:01"
          MAC2="52:54:00:03:09:02"
          ;;
        node10)
          MAC1="52:54:00:03:0A:01"
          MAC2="52:54:00:03:0A:02"          
          ;;
        node11)
          MAC1="52:54:00:03:0B:01"
          MAC2="52:54:00:03:0B:02"
          ;;
        node12)
          MAC1="52:54:00:03:0C:01"
          MAC2="52:54:00:03:0C:02"          
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
                --disk "$NAME"_1.img,size=$DISK_SIZE_GB_1,serial=workaround-lp-1876258-"$NAME"_1 \
                --disk "$NAME"_2.img,size=$DISK_SIZE_GB_2,serial=workaround-lp-1876258-"$NAME"_2 \
                --disk "$NAME"_3.img,size=$DISK_SIZE_GB_3,serial=workaround-lp-1876258-"$NAME"_3 \
                --boot network

done
