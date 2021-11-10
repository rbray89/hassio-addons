ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8
UN echo "**** install build packages ****" && \
	apk add --no-cache --virtual=build-dependencies --upgrade \
	autoconf \
	automake \
	cmake \
	curl-dev \
	doxygen \
	fakeroot \
	ffmpeg-dev \
	fftw-dev \
	gengetopt \
	g++ \
	gcc \
	git \
	glib-dev \
	graphviz \
	gtk-doc \
	jansson-dev \
	jpeg-dev \
	libpng-dev \
	libtool \
	make \
	mpg123-dev \
	libconfig-dev \
	libogg-dev \
	libmicrohttpd-dev \
	libnice \
	libnice-dev \
	libwebsockets-dev \
	lua5.3-dev \
	openjpeg-dev \
	openssl-dev \
	opus-dev \
	pkgconf \
	python3-dev \
	sudo \
	zlib-dev

RUN git clone https://github.com/sctplab/usrsctp && cd usrsctp && ./bootstrap \
	&& ./configure CFLAGS="-Wno-error=cpp" --prefix=/usr && make && sudo make install && rm -fr /usrsctp

RUN wget https://github.com/cisco/libsrtp/archive/v2.3.0.tar.gz \
        && tar xfv v2.3.0.tar.gz  && cd libsrtp-2.3.0 \
        && ./configure --prefix=/usr --enable-openssl \
        && make shared_library && sudo make install && rm -fr /libsrtp-2.3.0 && rm -f /v2.3.0.tar.gz

# Janus WebRTC Installation

RUN mkdir -p /usr/src/janus /var/janus/log /var/janus/data /var/janus/html \
	&& cd /usr/src/janus && wget https://github.com/meetecho/janus-gateway/archive/v0.10.8.tar.gz \
	&& tar -xzf v0.10.8.tar.gz && cd janus-gateway-0.10.8 \
	&& cp -r /usr/src/janus/janus-gateway-0.10.8/html/* /var/janus/html \
	&& sh autogen.sh \
	&& ./configure --prefix=/var/janus --disable-rabbitmq --disable-mqtt \
	&& make && make install && make configs \
	&& rm -rf /usr/src/janus 


COPY conf/janus.transport.http.jcfg /var/janus/etc/janus/janus.transport.http.jcfg
COPY conf/janus.jcfg /var/janus/etc/janus/janus.jcfg

# Copy data
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
