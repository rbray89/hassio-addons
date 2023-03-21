ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8
ENV GOPATH /opt/go

RUN  apk add --no-cache -U --virtual .build-deps \
        build-base \
        wget \
        git \
        go \
    &&   apk add --update -U --no-cache \
      ca-certificates \
      haproxy \
    &&   update-ca-certificates \
    && go install github.com/quantumew/mustache-cli@latest \
    && cp $GOPATH/bin/* /usr/local/bin/ \
    && rm -rf $GOPATH \
    && apk del .build-deps

# Copy data
COPY run.sh /
COPY config.mustache /templates/
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
