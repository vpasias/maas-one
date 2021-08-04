#!/bin/sh

for i in maas controller node1 node2 node3 node4 node5 node6 node7 node8 node9 node10 node11 node12; do
        virsh destroy $i
        virsh undefine $i --remove-all-storage
done
