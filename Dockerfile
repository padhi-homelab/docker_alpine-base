FROM alpine:3.23.0

LABEL maintainer="Saswat Padhi saswat.sourav@gmail.com"

COPY docker-entrypoint.sh \
     /usr/local/bin/docker-entrypoint

RUN apk add --no-cache --update \
            'su-exec==0.3-r0' \
            'tini==0.19.0-r3' \
 && chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT [ "tini" , "/usr/local/bin/docker-entrypoint" ]

CMD [ "sh" ]
