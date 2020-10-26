FROM alpine:3.12

LABEL maintainer="Saswat Padhi saswat.sourav@gmail.com"

COPY docker-entrypoint.sh \
     /usr/local/bin/docker-entrypoint

RUN apk add --no-cache --update \
        su-exec \
        tini \
 && rm -rf /var/lib/cache/* \
 && chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT [ "tini" , "/usr/local/bin/docker-entrypoint" ]
