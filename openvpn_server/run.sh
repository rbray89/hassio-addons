#!/bin/bash
set -e
CONFIG_PATH="/data/options.json"

mkdir -p /ssl/openvpn_server
if [ ! -e /ssl/openvpn_server/dhparam.pem ]; then
    openssl dhparam -dsaparam -out /ssl/openvpn_server/dhparam.pem 4096
fi

mustache-cli $CONFIG_PATH /templates/server.mustache > /etc/openvpn/server.conf
mustache-cli $CONFIG_PATH /templates/client.mustache > /etc/openvpn/client-common.txt

add_client () {
    mkdir -p /share/openvpn/clients
    client="$1"
    echo "Adding the client $client..."

    # Generates the custom client.ovpn
    cp /etc/openvpn/client-common.txt /share/openvpn/clients/$client.ovpn

    echo "<ca>" >> /share/openvpn/clients/$client.ovpn
    cat /ssl/openvpn_server/pki/ca.crt >> /share/openvpn/clients/$client.ovpn
    echo "</ca>" >>/share/openvpn/clients/$client.ovpn

    echo "<cert>" >> /share/openvpn/clients/$client.ovpn
    cat /ssl/openvpn_server/pki/issued/$client.crt >> /share/openvpn/clients/$client.ovpn
    echo "</cert>" >> /share/openvpn/clients/$client.ovpn

    echo "<key>" >> /share/openvpn/clients/$client.ovpn
    cat /ssl/openvpn_server/pki/private/$client.key >> /share/openvpn/clients/$client.ovpn
    echo "</key>" >> /share/openvpn/clients/$client.ovpn

    echo "<tls-auth>" >> /share/openvpn/clients/$client.ovpn
    cat /ssl/openvpn_server/ta.key >> /share/openvpn/clients/$client.ovpn
    echo "</tls-auth>" >> /share/openvpn/clients/$client.ovpn
}

server_certs () {
    cd /ssl/openvpn_server

    # Create the PKI, set up the CA and the server and client certificates
    /etc/openvpn/easy-rsa/easyrsa init-pki
    /etc/openvpn/easy-rsa/easyrsa --batch build-ca nopass
    EASYRSA_CERT_EXPIRE=3650 /etc/openvpn/easy-rsa/easyrsa build-server-full server nopass
    EASYRSA_CRL_DAYS=3650 /etc/openvpn/easy-rsa/easyrsa gen-crl

    # CRL is read with each client connection, when OpenVPN is dropped to nobody
    chown nobody:$GROUPNAME /ssl/openvpn_server/pki/crl.pem
    # Generate key for tls-auth
    openvpn --genkey --secret /ssl/openvpn_server/ta.key
}

if [ ! -e /ssl/openvpn_server/ta.key ]; then
    server_certs
fi

echo 'server'>/tmp/clients
cd /ssl/openvpn_server
jq --raw-output '.clients' $CONFIG_PATH | jq -rc '.[]' | while read CLIENT; do
   if [ ! -f /share/openvpn/clients/$CLIENT.ovpn ]; then
        EASYRSA_CERT_EXPIRE=3650 /etc/openvpn/easy-rsa/easyrsa build-client-full $CLIENT nopass
        add_client $CLIENT
   fi
   echo adding "$CLIENT"
   echo "$CLIENT">>/tmp/clients
done

echo Authorized certs:
cat /tmp/clients

for CLIENT in `ls /ssl/openvpn_server/pki/issued/*.crt | sed -r 's/.*\/([^\/]+).crt/\1/'`; do
  if ! grep -Fxq "$CLIENT" /tmp/clients ; then
    echo depricating $CLIENT
cat << EOF | /etc/openvpn/easy-rsa/easyrsa revoke $CLIENT
yes
EOF
    rm /ssl/openvpn_server/pki/issued/$CLIENT.crt
    rm /share/openvpn/clients/$CLIENT.ovpn
  fi
done
/etc/openvpn/easy-rsa/easyrsa gen-crl

# forward request and error logs to docker log collector
ln -sf /proc/1/fd/1 /var/log/openvpn-status.log

if ([ ! -c /dev/net/tun ] ); then
  if ( [ ! -d /dev/net ] ); then
    mkdir -m 755 /dev/n et
  fi
  echo "Creating /dev/net/tun..."
  mknod /dev/net/tun c 10 200
  chmod 666 /dev/net/tun
  ls -la /dev/net/tun
fi

rm -rf /etc/iptables
mkdir /etc/iptables

PROTOCOL=$(jq -rc '.protocol' $CONFIG_PATH)
PORT=1194
NIC=$(ip -4 route ls | grep default | cut -d ' ' -f5)
IPV6=$(jq -rc '.ipv6' $CONFIG_PATH)

echo "#!/bin/sh
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $NIC -j MASQUERADE
iptables -A INPUT -i tun0 -j ACCEPT
iptables -A FORWARD -i $NIC -o tun0 -j ACCEPT
iptables -A FORWARD -i tun0 -o $NIC -j ACCEPT
iptables -A FORWARD -s 10.8.0.0/24 -j ACCEPT
iptables -A FORWARD -d 10.8.0.0/24 -j ACCEPT
iptables -A INPUT -i $NIC -p $PROTOCOL --dport $PORT -j ACCEPT" > /etc/iptables/add-openvpn-rules.sh

echo "#!/bin/sh
iptables -t nat -D POSTROUTING -s 10.8.0.0/24 -o $NIC -j MASQUERADE
iptables -D INPUT -i tun0 -j ACCEPT
iptables -D FORWARD -i $NIC -o tun0 -j ACCEPT
iptables -D FORWARD -i tun0 -o $NIC -j ACCEPT
iptables -D INPUT -i $NIC -p $PROTOCOL --dport $PORT -j ACCEPT" > /etc/iptables/rm-openvpn-rules.sh

if [ "$IPV6" == "true" ]; then
    echo "ip6tables -t nat -A POSTROUTING -s fd42:42:42:42::/112 -o $NIC -j MASQUERADE
ip6tables -A INPUT -i tun0 -j ACCEPT
ip6tables -A FORWARD -i $NIC -o tun0 -j ACCEPT
ip6tables -A FORWARD -i tun0 -o $NIC -j ACCEPT" >> /etc/iptables/add-openvpn-rules.sh

    echo "ip6tables -t nat -D POSTROUTING -s fd42:42:42:42::/112 -o $NIC -j MASQUERADE
ip6tables -D INPUT -i tun0 -j ACCEPT
ip6tables -D FORWARD -i $NIC -o tun0 -j ACCEPT
ip6tables -D FORWARD -i tun0 -o $NIC -j ACCEPT" >> /etc/iptables/rm-openvpn-rules.sh
fi

chmod +x /etc/iptables/add-openvpn-rules.sh
chmod +x /etc/iptables/rm-openvpn-rules.sh

#cat /etc/iptables/add-openvpn-rules.sh
#echo `ip -4 route ls`
cat /proc/sys/net/ipv4/ip_forward

/etc/iptables/add-openvpn-rules.sh

cat /etc/openvpn/server.conf
openvpn --config /etc/openvpn/server.conf
