chmod +x cloudlab-setup-ubuntu-tl.sh && ./cloudlab-setup-ubuntu-tl.sh && \
sudo apt-get install libvirt-bin genisoimage libguestfs-tools libosinfo-bin virtinst qemu-kvm git vim net-tools wget curl bash-completion python-pip libvirt-daemon-system virt-manager bridge-utils libnss-libvirt libvirt-clients osinfo-db-tools intltool sshpass htop -y && \
sudo sed -i 's/hosts:          files dns/hosts:          files libvirt libvirt_guest dns/' /etc/nsswitch.conf && sudo lsmod | grep kvm && sudo reboot
#sudo systemctl restart libvirtd && sudo systemctl status libvirtd

screen
# Press Return to continue
# detach from session without killing it: Ctrl a d 
# to see screen sessions: screen -ls
# detach from closed session: screen -d -r 1924.pts-0.node0
# enter session: screen -r 1924.pts-0.node0
# exit a session and terminate it: exit

sudo -i

# Create OS node VMs
cd /mnt/extra && cat /sys/module/kvm_intel/parameters/nested && cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l && free -h && df -hT && sudo virsh list --all && sudo brctl show && \
mkdir -p /mnt/extra/virt/images && mkdir -p /mnt/extra/virt/vms && \
wget -O "/mnt/extra/osinfo-db.tar.xz" https://releases.pagure.org/libosinfo/osinfo-db-20200813.tar.xz && sudo osinfo-db-import --local "/mnt/extra/osinfo-db.tar.xz" && \
cd /mnt/extra/ && git clone https://github.com/giovtorres/kvm-install-vm.git && cd kvm-install-vm

sudo apt install snapd -y && sudo snap install juju --classic

###########################################################################################################################################################################################
################################## MAAS One (https://github.com/vpasias/maas-one) ###############################################
###########################################################################################################################################################################################

nano vm_deployment.sh

#!/bin/bash
#

virsh net-destroy default && virsh net-undefine default

cat > /mnt/extra/net-external.xml <<EOF
<network>                                                                       
  <name>external</name>                                                         
  <uuid>790274ec-2590-4854-b432-ea7d22deb667</uuid>                             
  <forward mode='nat'>                                                          
    <nat>                                                                       
      <port start='1024' end='65535'/>                                          
    </nat>                                                                      
  </forward>                                                                    
  <bridge name='virbr0' stp='on' delay='0'/>                                    
  <mac address='52:54:00:c9:86:40'/>                                            
  <ip address='192.168.122.1' netmask='255.255.255.0'>                          
    <dhcp>                                                                      
      <range start='192.168.122.2' end='192.168.122.254'/>                      
      <host mac='52:54:00:01:01:01' ip='192.168.122.2' />                       
    </dhcp>                                                                     
  </ip>                                                                         
</network> 
EOF

cat > /mnt/extra/net-internal.xml <<EOF
<network>                                                                       
  <name>internal</name>                                                         
  <uuid>790274ec-2590-4854-b432-ea7d22deb668</uuid>                             
  <forward mode='nat'>                                                          
    <nat>                                                                       
      <port start='1024' end='65535'/>                                          
    </nat>                                                                      
  </forward>                                                                    
  <bridge name='virbr1' stp='on' delay='0'/>                                    
  <mac address='52:54:00:c9:86:41'/>                                            
  <ip address='10.0.0.1' netmask='255.255.255.0'>                               
  </ip>                                                                         
</network>
EOF

virsh net-define /mnt/extra/net-internal.xml && virsh net-autostart internal && virsh net-start internal
virsh net-define /mnt/extra/net-external.xml && virsh net-autostart external && virsh net-start external

virsh net-list --all

./kvm-install-vm create -c 4 -m 8192 -d 80 -t ubuntu2004 -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b virbr0 -T US/Eastern -M 52:54:00:01:01:01 maashost

virsh attach-interface --domain maashost --type network --source internal --model virtio --mac 52:54:00:01:01:02 --config --live
virsh list --all && brctl show && virsh net-list --all

sleep 90

ssh -o "StrictHostKeyChecking=no" ubuntu@maashost "uname -a && sudo ip a"

ssh -o "StrictHostKeyChecking=no" ubuntu@maashost 'echo "root:gprm8350" | sudo chpasswd'
ssh -o "StrictHostKeyChecking=no" ubuntu@maashost 'echo "ubuntu:kyax7344" | sudo chpasswd' 
ssh -o "StrictHostKeyChecking=no" ubuntu@maashost "sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config"
ssh -o "StrictHostKeyChecking=no" ubuntu@maashost "sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config" 
ssh -o "StrictHostKeyChecking=no" ubuntu@maashost "sudo systemctl restart sshd"
ssh -o "StrictHostKeyChecking=no" ubuntu@maashost "sudo rm -rf /root/.ssh/authorized_keys"

ssh -o "StrictHostKeyChecking=no" ubuntu@maashost "cat << EOF | sudo tee /etc/modprobe.d/qemu-system-x86.conf
options kvm_intel nested=1
EOF"

ssh -o "StrictHostKeyChecking=no" ubuntu@maashost "sudo rm -rf /etc/netplan/01-netcfg.yaml"

ssh -o "StrictHostKeyChecking=no" ubuntu@maashost "cat << EOF | sudo tee /etc/netplan/01-netcfg.yaml
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
    ens3:
      dhcp4: true
      match:
          macaddress: '52:54:00:01:01:01'
      set-name: ens3
    ens10:
      dhcp4: false
      match:
          macaddress: '52:54:00:01:01:02'
      set-name: ens10
      addresses:
        - 10.0.0.2/24
EOF"

ssh -o "StrictHostKeyChecking=no" ubuntu@maashost "sudo apt update -y && sudo apt upgrade -y && sudo apt install vim git wget net-tools locate jq -y"

ssh -o "StrictHostKeyChecking=no" ubuntu@maashost "sudo apt-get install qemu-kvm libvirt-daemon-system libvirt-daemon virtinst bridge-utils libosinfo-bin libguestfs-tools virt-top -y"
ssh -o "StrictHostKeyChecking=no" ubuntu@maashost "sudo snap install maas-test-db"
ssh -o "StrictHostKeyChecking=no" ubuntu@maashost "sudo snap install maas --channel=2.9/stable"
ssh -o "StrictHostKeyChecking=no" ubuntu@maashost "sudo maas init region+rack --maas-url http://10.0.0.2:5240/MAAS --database-uri maas-test-db:///"
ssh -o "StrictHostKeyChecking=no" ubuntu@maashost "sudo maas createadmin --username admin --password ubuntu --email admin@example.com"
ssh -o "StrictHostKeyChecking=no" ubuntu@maashost "sudo maas apikey --username admin > ~ubuntu/admin-api-key"
ssh -o "StrictHostKeyChecking=no" ubuntu@maashost "sudo mkdir -p /var/snap/maas/current/root/.ssh"
ssh -o "StrictHostKeyChecking=no" ubuntu@maashost "sudo ssh-keygen -q -N '' -f /var/snap/maas/current/root/.ssh/id_rsa"

ssh -o "StrictHostKeyChecking=no" ubuntu@maashost "sudo netplan apply"
ssh -o "StrictHostKeyChecking=no" ubuntu@maashost "sudo reboot"
#

chmod +x vm_deployment.sh && ./vm_deployment.sh

git clone https://github.com/vpasias/maas-one.git && cd maas-one

ssh -o "StrictHostKeyChecking=no" ubuntu@maashost uname -a

scp -o "StrictHostKeyChecking=no" ubuntu@maashost:admin-api-key ~

ssh -o "StrictHostKeyChecking=no" ubuntu@maashost
cat /sys/module/kvm_intel/parameters/nested && cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l && free -h && df -hT && ip a && lsblk
# sudo systemctl status libvirtd
sudo -i
cat /var/snap/maas/current/root/.ssh/id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys
exit
sudo snap run --shell maas
virsh -c qemu+ssh://ubuntu@10.0.0.2/system list --all
exit
exit

scp -o "StrictHostKeyChecking=no" config-maas.sh config-nodes.sh maas-login.sh ubuntu@maashost:

nc -vz 10.0.0.2 5240
#Connection to 10.0.0.2 5240 port [tcp/*] succeeded!

ssh -o "StrictHostKeyChecking=no" ubuntu@maashost ./config-maas.sh

# 5240 -> 10.0.0.2:5240
# URL: http://localhost:5240/MAAS/

./create-nodes.sh

ssh -o "StrictHostKeyChecking=no" ubuntu@maashost ./config-nodes.sh

./cloud-and-creds.sh

juju clouds --client && juju credentials --client --show-secrets --format yaml

juju bootstrap --bootstrap-series=focal --bootstrap-constraints tags=juju maas-one maas-one && juju add-model --config default-series=focal openstack && mkdir -p bundles/ && cd bundles

juju controllers && juju status && juju machines

cat > tfhabundle.yaml <<EOF
series: focal
applications:
  ceph-mon:
    charm: cs:ceph-mon-55
    channel: stable
    num_units: 3
    to:
    - lxd:0
    - lxd:1
    - lxd:2
    options:
      expected-osd-count: 3
    constraints: arch=amd64
  ceph-osd:
    charm: cs:ceph-osd-310
    channel: stable
    num_units: 3
    to:
    - "0"
    - "1"
    - "2"
    options:
      osd-devices: /dev/vdb
    constraints: arch=amd64
  dashboard-mysql-router:
    charm: cs:mysql-router-8
    channel: stable
    options:
      source: distro
  easyrsa:
    charm: cs:~containers/easyrsa-373
    channel: stable
    num_units: 1
    to:
    - "0"
    constraints: arch=amd64
  glance:
    charm: cs:glance-305
    channel: stable
    num_units: 3
    to:
    - lxd:0
    - lxd:1
    - lxd:2
    expose: true
    options:
      debug: true
      openstack-origin: distro
      vip: 10.0.0.103
    constraints: arch=amd64
  glance-mysql-router:
    charm: cs:mysql-router-8
    channel: stable
    options:
      source: distro
  hacluster-glance:
    charm: cs:hacluster-76
    channel: stable
  hacluster-heat:
    charm: cs:hacluster-76
    channel: stable
  hacluster-keystone:
    charm: cs:hacluster-76
    channel: stable
  hacluster-neutron:
    charm: cs:hacluster-76
    channel: stable
  hacluster-nova:
    charm: cs:hacluster-76
    channel: stable
  hacluster-placement:
    charm: cs:hacluster-76
    channel: stable
  hacluster-swift-proxy:
    charm: cs:hacluster-76
    channel: stable
  haproxy:
    charm: cs:haproxy-61
    channel: stable
    num_units: 3
    to:
    - "0"
    - "1"
    - "2"
    expose: true
    options:
      enable_monitoring: true
      peering_mode: active-active
      ssl_cert: SELFSIGNED
    constraints: arch=amd64
  heat:
    charm: cs:heat-283
    channel: stable
    num_units: 3
    to:
    - lxd:0
    - lxd:1
    - lxd:2
    expose: true
    options:
      debug: true
      openstack-origin: distro
      vip: 10.0.0.102
    constraints: arch=amd64
  heat-mysql-router:
    charm: cs:mysql-router-8
    channel: stable
    options:
      source: distro
  keepalived:
    charm: cs:~containers/keepalived-64
    channel: stable
    options:
      port: 10000
      virtual_ip: 10.0.0.101
  keystone:
    charm: cs:keystone-323
    channel: stable
    num_units: 3
    to:
    - lxd:0
    - lxd:1
    - lxd:2
    expose: true
    options:
      admin-password: password
      admin-role: admin
      debug: true
      openstack-origin: distro
      preferred-api-version: 3
      vip: 10.0.0.104
    constraints: arch=amd64
  keystone-mysql-router:
    charm: cs:mysql-router-8
    channel: stable
    options:
      source: distro
  memcached:
    charm: cs:memcached-32
    channel: stable
    num_units: 3
    to:
    - lxd:0
    - lxd:1
    - lxd:2
    options:
      allow-ufw-ip6-softfail: true
    constraints: arch=amd64
  mysql-innodb-cluster:
    charm: cs:mysql-innodb-cluster-8
    channel: stable
    num_units: 3
    to:
    - lxd:0
    - lxd:1
    - lxd:2
    options:
      max-connections: 1500
      source: distro
    constraints: arch=amd64
  neutron-api:
    charm: cs:neutron-api-294
    channel: stable
    num_units: 3
    to:
    - lxd:0
    - lxd:1
    - lxd:2
    expose: true
    options:
      debug: true
      manage-neutron-plugin-legacy-mode: false
      neutron-security-groups: true
      openstack-origin: distro
      vip: 10.0.0.106
    constraints: arch=amd64
  neutron-mysql-router:
    charm: cs:mysql-router-8
    channel: stable
    options:
      source: distro
  nova-cloud-controller:
    charm: cs:nova-cloud-controller-355
    channel: stable
    num_units: 3
    to:
    - lxd:0
    - lxd:1
    - lxd:2
    expose: true
    options:
      cache-known-hosts: false
      console-access-protocol: novnc
      debug: true
      network-manager: Neutron
      openstack-origin: distro
      vip: 10.0.0.107
    constraints: arch=amd64
  nova-compute:
    charm: cs:nova-compute-327
    channel: stable
    num_units: 2
    to:
    - "3"
    - "4"
    options:
      debug: true
      enable-live-migration: true
      enable-resize: true
      libvirt-image-backend: rbd
      migration-auth-type: ssh
      openstack-origin: distro
      virt-type: kvm
    constraints: arch=amd64
  nova-mysql-router:
    charm: cs:mysql-router-8
    channel: stable
    options:
      source: distro
  ntp:
    charm: cs:ntp-41
    channel: stable
  openstack-dashboard:
    charm: cs:openstack-dashboard-313
    channel: stable
    num_units: 1
    to:
    - lxd:2
    expose: true
    options:
      debug: "true"
      openstack-origin: distro
    constraints: arch=amd64
  placement:
    charm: cs:placement-19
    channel: stable
    num_units: 3
    to:
    - lxd:0
    - lxd:1
    - lxd:2
    options:
      debug: true
      openstack-origin: distro
      vip: 10.0.0.108
    constraints: arch=amd64
  placement-mysql-router:
    charm: cs:mysql-router-8
    channel: stable
    options:
      source: distro
  rabbitmq-server:
    charm: cs:rabbitmq-server-110
    channel: stable
    num_units: 3
    to:
    - lxd:0
    - lxd:1
    - lxd:2
    options:
      min-cluster-size: 3
    constraints: arch=amd64
  swift-proxy:
    charm: cs:swift-proxy-99
    channel: stable
    num_units: 3
    to:
    - lxd:0
    - lxd:1
    - lxd:2
    options:
      debug: true
      openstack-origin: distro
      replicas: 3
      vip: 10.0.0.109
      zone-assignment: manual
    constraints: arch=amd64
  swift-storage1:
    charm: cs:swift-storage-276
    channel: stable
    num_units: 1
    to:
    - "0"
    options:
      block-device: /etc/swift/storagedev1.img|15G
      openstack-origin: distro
      zone: 1
    constraints: arch=amd64
  swift-storage2:
    charm: cs:swift-storage-276
    channel: stable
    num_units: 1
    to:
    - "1"
    options:
      block-device: /etc/swift/storagedev1.img|15G
      openstack-origin: distro
      zone: 2
    constraints: arch=amd64
  swift-storage3:
    charm: cs:swift-storage-276
    channel: stable
    num_units: 1
    to:
    - "2"
    options:
      block-device: /etc/swift/storagedev1.img|15G
      openstack-origin: distro
      zone: 3
    constraints: arch=amd64
  tf-agent:
    charm: cs:~juniper-os-software/contrail-agent
    options:
      docker-registry: tungstenfabric
      docker-registry-insecure: true
      image-tag: latest
      kernel-hugepages-1g: ""
      log-level: SYS_DEBUG
  tf-analytics:
    charm: cs:~juniper-os-software/contrail-analytics
    num_units: 3
    to:
    - "0"
    - "1"
    - "2"
    expose: true
    options:
      control-network: 10.0.0.0/24
      docker-registry: tungstenfabric
      docker-registry-insecure: true
      image-tag: latest
      log-level: SYS_DEBUG
      min-cluster-size: 3
      vip: 10.0.0.101
    constraints: arch=amd64
  tf-analyticsdb:
    charm: cs:~juniper-os-software/contrail-analyticsdb
    num_units: 3
    to:
    - "0"
    - "1"
    - "2"
    expose: true
    options:
      cassandra-jvm-extra-opts: -Xms16g -Xmx16g
      cassandra-minimum-diskgb: "4"
      control-network: 10.0.0.0/24
      docker-registry: tungstenfabric
      docker-registry-insecure: true
      image-tag: latest
      log-level: SYS_DEBUG
      min-cluster-size: 3
    constraints: arch=amd64
  tf-controller:
    charm: cs:~juniper-os-software/contrail-controller
    num_units: 3
    to:
    - "0"
    - "1"
    - "2"
    expose: true
    options:
      auth-mode: rbac
      cassandra-jvm-extra-opts: -Xms16g -Xmx16g
      cassandra-minimum-diskgb: "4"
      control-network: 10.0.0.0/24
      data-network: 172.16.0.0/16
      docker-registry: tungstenfabric
      docker-registry-insecure: true
      image-tag: latest
      log-level: SYS_DEBUG
      min-cluster-size: 3
      vip: 10.0.0.101
    constraints: arch=amd64
  tf-keystone-auth:
    charm: cs:~juniper-os-software/contrail-keystone-auth
    num_units: 1
    to:
    - "0"
    constraints: arch=amd64
  tf-openstack:
    charm: cs:~juniper-os-software/contrail-openstack
    options:
      docker-registry: tungstenfabric
      docker-registry-insecure: true
      image-tag: latest
  ubuntu:
    charm: cs:ubuntu-18
    channel: stable
    num_units: 5
    to:
    - "0"
    - "1"
    - "2"
    - "3"
    - "4"
    constraints: arch=amd64
machines:
  "0":
    constraints: cpu-cores=8 mem=32768 root-disk=307200
  "1":
    constraints: cpu-cores=8 mem=32768 root-disk=307200
  "2":
    constraints: cpu-cores=8 mem=32768 root-disk=307200
  "3":
    constraints: cpu-cores=8 mem=32768 root-disk=307200
  "4":
    constraints: cpu-cores=8 mem=32768 root-disk=307200
relations:
- - nova-compute:amqp
  - rabbitmq-server:amqp
- - nova-compute:image-service
  - glance:image-service
- - nova-cloud-controller:cloud-compute
  - nova-compute:cloud-compute
- - nova-compute:ceph
  - ceph-mon:client
- - placement:identity-service
  - keystone:identity-service
- - placement:placement
  - nova-cloud-controller:placement
- - placement:ha
  - hacluster-placement:ha
- - nova-cloud-controller:identity-service
  - keystone:identity-service
- - glance:identity-service
  - keystone:identity-service
- - neutron-api:identity-service
  - keystone:identity-service
- - neutron-api:amqp
  - rabbitmq-server:amqp
- - glance:amqp
  - rabbitmq-server:amqp
- - nova-cloud-controller:image-service
  - glance:image-service
- - nova-cloud-controller:amqp
  - rabbitmq-server:amqp
- - openstack-dashboard:identity-service
  - keystone:identity-service
- - nova-cloud-controller:neutron-api
  - neutron-api:neutron-api
- - heat:amqp
  - rabbitmq-server:amqp
- - heat:identity-service
  - keystone:identity-service
- - ubuntu:juju-info
  - ntp:juju-info
- - keystone:shared-db
  - keystone-mysql-router:shared-db
- - keystone-mysql-router:db-router
  - mysql-innodb-cluster:db-router
- - glance:shared-db
  - glance-mysql-router:shared-db
- - glance-mysql-router:db-router
  - mysql-innodb-cluster:db-router
- - nova-cloud-controller:shared-db
  - nova-mysql-router:shared-db
- - nova-mysql-router:db-router
  - mysql-innodb-cluster:db-router
- - neutron-api:shared-db
  - neutron-mysql-router:shared-db
- - neutron-mysql-router:db-router
  - mysql-innodb-cluster:db-router
- - openstack-dashboard:shared-db
  - dashboard-mysql-router:shared-db
- - dashboard-mysql-router:db-router
  - mysql-innodb-cluster:db-router
- - heat:shared-db
  - heat-mysql-router:shared-db
- - heat-mysql-router:db-router
  - mysql-innodb-cluster:db-router
- - placement:shared-db
  - placement-mysql-router:shared-db
- - placement-mysql-router:db-router
  - mysql-innodb-cluster:db-router
- - keystone:ha
  - hacluster-keystone:ha
- - heat:ha
  - hacluster-heat:ha
- - glance:ha
  - hacluster-glance:ha
- - neutron-api:ha
  - hacluster-neutron:ha
- - nova-cloud-controller:ha
  - hacluster-nova:ha
- - glance:ceph
  - ceph-mon:client
- - ceph-osd:mon
  - ceph-mon:osd
- - nova-cloud-controller:memcache
  - memcached:cache
- - tf-controller:contrail-analytics
  - tf-analytics:contrail-analytics
- - tf-controller:contrail-analyticsdb
  - tf-analyticsdb:contrail-analyticsdb
- - tf-analytics:contrail-analyticsdb
  - tf-analyticsdb:contrail-analyticsdb
- - tf-agent:contrail-controller
  - tf-controller:contrail-controller
- - easyrsa:client
  - tf-controller:tls-certificates
- - easyrsa:client
  - tf-analytics:tls-certificates
- - easyrsa:client
  - tf-analyticsdb:tls-certificates
- - easyrsa:client
  - tf-agent:tls-certificates
- - tf-controller:contrail-auth
  - tf-keystone-auth:contrail-auth
- - tf-openstack:contrail-controller
  - tf-controller:contrail-controller
- - tf-controller:http-services
  - haproxy:reverseproxy
- - tf-controller:https-services
  - haproxy:reverseproxy
- - tf-analytics:http-services
  - haproxy:reverseproxy
- - keepalived:juju-info
  - haproxy:juju-info
- - tf-keystone-auth:identity-admin
  - keystone:identity-admin
- - tf-openstack:neutron-api
  - neutron-api:neutron-plugin-api-subordinate
- - tf-openstack:heat-plugin
  - heat:heat-plugin-subordinate
- - tf-openstack:nova-compute
  - nova-compute:neutron-plugin
- - tf-agent:juju-info
  - nova-compute:juju-info
- - swift-proxy:ha
  - hacluster-swift-proxy:ha
- - swift-proxy:swift-storage
  - swift-storage1:swift-storage
- - swift-proxy:swift-storage
  - swift-storage2:swift-storage
- - swift-proxy:swift-storage
  - swift-storage3:swift-storage
- - swift-proxy:identity-service
  - keystone:identity-service
- - swift-proxy:amqp
  - rabbitmq-server:amqp
EOF

juju deploy ./tfhabundle.yaml --map-machines=existing
juju machines
juju status

# Delete controller and model
juju destroy-controller maas-one -y --destroy-all-models
juju kill-controller -y maas-one

# Delete all
./remove-guests.sh && cd && rm -rf maas-one
