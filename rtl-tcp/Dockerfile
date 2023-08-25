ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

RUN apk add --no-cache coreutils \
    rtl-sdr \
    jq
WORKDIR /root

COPY rtlsn2dev.sh /
RUN chmod a+x /rtlsn2dev.sh

# Run script
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
