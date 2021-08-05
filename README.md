# Overview

This project installs a MAAS cluster on a single machine. 

Environment summary:

* 1 powerful host (the "KVM host") running Ubuntu 18.04 LTS or Ubuntu 20.04 LTS

* KVM guests residing on the KVM host:
     * 1 for the MAAS host itself
     * 1 for the Juju controller
     * 4-13 for the MAAS nodes (available for deployments)

* 2 libvirt networks:
     * 'external' for the external side of the MAAS host
     * 'internal' for the internal side of the MAAS host

* The KVM host, beyond hosting the guests, will act as the Juju client

The four guests destined for MAAS nodes are currently configured with a lot of
CPU power, a lot of memory, two network interfaces, and three disks. This is
because the original intent was the deployment of [Charmed OpenStack][cdg].
Adjust per your needs and desires by modifying `create-nodes.sh`.

Before you begin, look over all the files. They're pretty simple.

> **Note**: File ``OPENSTACK.md`` contains instructions for applying this
  solution to an OpenStack cloud. It shows how to configure and use OpenStack.
  It does not show how to **build** the cloud.

## General topology

                          |
               eth0 +-----+
                          |
    +-------------------------------------------+
    | MAAS host           |       MAAS host     |
    | 192.168.122.2       |       10.0.0.2      |
    |                     |                     |
    |                     +-----+ virbr1        |
    |                     |       10.0.0.1      |
    |        virbr0 +-----+                     |
    | 192.168.122.1       |                     |
    +-------------------------------------------+
      192.168.122.0/24    | 10.0.0.0/24
      external            | internal
                          |
      libvirt DHCP on     | libvirt DHCP off
                          | MAAS DHCP on

## MAAS node network

Subnet DNS: `10.0.0.2`

Subnet gateway: `10.0.0.1`

Reserved IP ranges:

    10.0.0.1   - 10.0.0.9     Infra     <-- infrastructure
    10.0.0.10  - 10.0.0.39    Dynamic   <-- MAAS DHCP (enlistment, commissioning)
    10.0.0.40  - 10.0.0.99    FIP       <-- OpenStack floating IPs (if needed)
    10.0.0.100 - 10.0.0.119   VIP       <-- HA workloads (if needed)

So deployed nodes will use:

    10.0.0.120 - 10.0.0.254

## Set up the environment

Follow the instructions in the file: installation.txt
