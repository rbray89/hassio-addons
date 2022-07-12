ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8
RUN buildDeps="libglib2.0-doc wget build-essential git debhelper debhelper-compat meson graphviz gobject-introspection gtk-doc-tools libgirepository1.0-dev libglib2.0-dev libgnutls28-dev libgstreamer1.0-dev libgupnp-igd-1.0-dev autotools-dev dh-autoreconf gengetopt libavcodec-dev libavformat-dev libavutil-dev libconfig-dev libcurl4-openssl-dev libcurl4-openssl-dev libjansson-dev liblua5.3-dev libmicrohttpd-dev libnanomsg-dev libogg-dev libopus-dev librabbitmq-dev libre-dev libsofia-sip-ua-dev libssl-dev libsystemd-dev libusrsctp-dev libwebsockets-dev pkg-config rename fakeroot gir1.2-glib-2.0 libgirepository-1.0-1 " \
    && runDeps="avahi-daemon libnss-mdns" \
    && echo 'APT::Install-Recommends "false";' >/etc/apt/apt.conf.d/00recommends \
    && echo 'APT::Install-Suggests "false";' >>/etc/apt/apt.conf.d/00recommends \
    && apt-get update \
    && apt-get install -y $buildDeps $runDeps \
    && git clone --depth 1 --single-branch --branch debian/0.1.16-1 https://salsa.debian.org/telepathy-team/libnice.git /tmp/libnice \
    && cd /tmp/libnice \
    && dpkg-buildpackage -b --no-sign -rfakeroot \
    && dpkg -i ../*.deb \
    && apt-get clean \
    && rm -rf /tmp/* \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/sctplab/usrsctp && cd usrsctp && ./bootstrap \
    && ./configure CFLAGS="-Wno-error=cpp" --prefix=/usr && make && make install && rm -fr /usrsctp

RUN wget https://github.com/cisco/libsrtp/archive/v2.4.2.tar.gz \
    && tar xfv v2.4.2.tar.gz  && cd libsrtp-2.4.2 \
    && ./configure --prefix=/usr --enable-openssl \
    && make shared_library && make install && rm -fr /libsrtp-2.4.2 && rm -f /v2.4.2.tar.gz   

# Janus WebRTC Installation
RUN mkdir -p /usr/src/janus /var/janus/log /var/janus/data /var/janus/html \
	&& cd /usr/src/janus && wget https://github.com/meetecho/janus-gateway/archive/v0.11.7.tar.gz \
	&& tar -xzf v0.11.7.tar.gz && cd janus-gateway-0.11.7 \
	&& cp -r /usr/src/janus/janus-gateway-0.11.7/html/* /var/janus/html \
        && sed -i 's/"upnp", FALSE/"upnp", TRUE/g' ice.c \
	&& sh autogen.sh \
	&& ./configure --disable-rabbitmq --disable-mqtt --disable-websockets \
	&& make CFLAGS="-Wno-cast-align" && make install && make configs


COPY conf/janus.transport.http.jcfg /usr/local/etc/janus/janus.transport.http.jcfg
COPY conf/janus.jcfg /usr/local/etc/janus/janus.jcfg

# Copy data
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
