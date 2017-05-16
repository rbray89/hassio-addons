# OpenVPN Server for hass.io

## Configuration

### host
Hostname that clients will use to reach the server. This should be either an IP adddress or fully qualified hostname.

### protocol
tcp or udp (recommended)

### port
Port that clients will use to reach the server. Note that if you change this in the config, you will need to also change the network port as well.

### ipv6
Some targets may not be able to setup IPv6 routing if the kernel modules are not already loaded. Disabled by default.

### compress
Enable/disable lzo compression

### clients
List of client names (no spaces) to be added.
After running, there will be \*.ovpn files for each client located in /share/openvpn/clients
Currently, if you want to re-generate the certs, you'll need to delete the /ssl/openvpn_server and /share/openvpn/clients directories and re-start the addon. This will invalidate the previous clients and generate new certs.
