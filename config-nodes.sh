#!/bin/bash                                                                                                                             
                                                                                                                                        
#set -e                                                                                                                                 
                                                                                                                                        
PROFILE=admin
KVM_INTERNAL_IP=10.0.0.1

declare -A nodeNamesMACs=( \
        [node1]=52:54:00:03:01:01 \
        [node2]=52:54:00:03:02:01 \
        [node3]=52:54:00:03:03:01 \
        [node4]=52:54:00:03:04:01 \
        [node5]=52:54:00:03:05:01 \
        [node6]=52:54:00:03:06:01 \
        [node7]=52:54:00:03:07:01 \
        [node8]=52:54:00:03:08:01 \
        [node9]=52:54:00:03:09:01 \
        [node10]=52:54:00:03:0A:01 \
        [node11]=52:54:00:03:0B:01 \
        [node12]=52:54:00:03:0C:01 \    
        [node13]=52:54:00:03:0D:01 \   
        [controller]=52:54:00:02:01:01 \
        )

maas $PROFILE tags create name=juju comment='Juju controller' >/dev/null && echo -ne "\nMAAS tag 'juju' created\n"

# For each KVM guest node:
for i in "${!nodeNamesMACs[@]}"; do
        echo -e "\nConfiguring node $i"
        MAC1=${nodeNamesMACs[$i]}
        SYSTEM_ID=$(maas $PROFILE machines read mac_address=$MAC1 | grep -i system_id -m 1 | cut -d '"' -f 4)
        maas $PROFILE machine update $SYSTEM_ID \
                hostname=$i \
                power_type=virsh \
                power_parameters_power_address=qemu+ssh://root@"$KVM_INTERNAL_IP"/system \
                power_parameters_power_id=$i >/dev/null && echo "- Node name changed and power type configured"
        maas $PROFILE machine commission $SYSTEM_ID testing_scripts=none >/dev/null && echo "- Node commissioning (hardware tests skipped)"

        # Node 'controller' is the Juju controller, apply tag 'juju'
        if [ $i = "controller" ]; then
                 maas $PROFILE tag update-nodes juju add=$SYSTEM_ID >/dev/null && echo "- Tag 'juju' assigned to node $i"
        fi

done
