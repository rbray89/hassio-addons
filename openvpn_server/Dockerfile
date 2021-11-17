ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8
ENV GOPATH /opt/go

# Setup base
RUN apk add --no-cache -U --virtual .build-deps \
        build-base \
        wget \
        git \
	go \
 && apk add --update -U --no-cache \
        jq \
        libressl \
        iptables \
        ip6tables \
        openssl \
        openvpn \
 && go get -u github.com/quantumew/mustache-cli \
 && cp $GOPATH/bin/* /usr/local/bin/ \
 && rm -rf $GOPATH \
 && wget https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.5/EasyRSA-nix-3.0.5.tgz -O ~/easyrsa.tgz \
 && apk del .build-deps

# Get easy-rsa
RUN tar xzf ~/easyrsa.tgz -C ~/
RUN mv ~/EasyRSA-3.0.5/ /etc/openvpn/
RUN mv /etc/openvpn/EasyRSA-3.0.5/ /etc/openvpn/easy-rsa/
RUN chown -R root:root /etc/openvpn/easy-rsa/
RUN rm -f ~/easyrsa.tgz

# Copy data
COPY run.sh /
COPY server.mustache /templates/
COPY client.mustache /templates/

RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
