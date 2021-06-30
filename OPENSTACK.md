# Using maas-one for an OpenStack cloud

This page provides command line guidance once OpenStack has been built using
the four MAAS nodes. All commands are invoked on the KVM host.

Begin by creating a Juju model:

    juju add-model --config default-series=focal openstack

Now follow the instructions starting here for building an OpenStack cloud:

https://docs.openstack.org/project-deploy-guide/charm-deployment-guide/latest/install-openstack.html#ceph-osd

> **Tips**: For file ``ceph-osd.yaml``, option ``osd-devices`` should be set to
  `/dev/vdb` and for file ``neutron.yaml``, the value of option
  ``bridge-interface-mappings`` will need to be changed (e.g.
  ``br-ex:enp2s0``).

## Base client requirements

    ssh-keygen -q -N '' -f /mnt/extra/.ssh/admin-key
    sudo snap install openstackclients --classic
    curl http://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img --output /mnt/extra/virt/images/focal-amd64.img
    git clone https://github.com/openstack-charmers/openstack-bundles /mnt/extra/openstack-bundles
    source /mnt/extra/openstack-bundles/stable/openstack-base/openrc

## OpenStack networking (and image)

    openstack image create --public --container-format bare --disk-format raw --property architecture=x86_64 --property hw_disk_bus=virtio --property hw_vif_model=virtio --file ~/focal-amd64.img focal-amd64
    openstack network create ext_net --external --share --default --provider-network-type flat --provider-physical-network physnet1
    openstack subnet create ext_subnet --allocation-pool start=10.0.0.40,end=10.0.0.99 --subnet-range 10.0.0.0/24 --no-dhcp --gateway 10.0.0.1 --network ext_net
    openstack network create int_net --internal
    openstack subnet create int_subnet --allocation-pool start=192.168.0.10,end=192.168.0.199 --subnet-range 192.168.0.0/24 --gateway 192.168.0.1 --dns-nameserver 10.0.0.2 --network int_net
    openstack router create router1
    openstack router add subnet router1 int_subnet
    openstack router set router1 --external-gateway ext_net

## OpenStack usage

### One-time setup

    openstack keypair create --public-key /mnt/extra/.ssh/admin-key.pub admin-key

    for i in $(openstack security group list | awk '/default/{ print $2 }'); do
        openstack security group rule create $i --protocol icmp --remote-ip 0.0.0.0/0;
        openstack security group rule create $i --protocol tcp --remote-ip 0.0.0.0/0 --dst-port 22;
    done

    openstack flavor create --public --ram 256 --disk 3 --ephemeral 3 --vcpus 1 m1.micro

    NET_ID=$(openstack network show int_net -f value -c id)

### Instance creation

    openstack server create --image focal-amd64 --flavor m1.micro --key-name admin-key --nic net-id=$NET_ID focal-1
    FLOATING_IP=$(openstack floating ip create -f value -c floating_ip_address ext_net)
    openstack server add floating ip focal-1 $FLOATING_IP

### Instance connection

This is recommended prior to attempting an SSH connection:

    openstack console log show focal-1

Connect:

    ssh -i /mnt/extra/.ssh/admin-key ubuntu@$FLOATING_IP
