FROM alpine:3.14.2

LABEL maintainer="Saswat Padhi saswat.sourav@gmail.com"

COPY docker-entrypoint.sh \
     /usr/local/bin/docker-entrypoint

RUN apk add --no-cache --update \
        'su-exec==0.2-r1' \
        'tini==0.19.0-r0' \
 && chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT [ "tini" , "/usr/local/bin/docker-entrypoint" ]

CMD [ "sh" ]
