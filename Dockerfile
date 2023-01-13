FROM alpine:3.17.1

LABEL maintainer="Saswat Padhi saswat.sourav@gmail.com"

COPY docker-entrypoint.sh \
     /usr/local/bin/docker-entrypoint

RUN apk add --no-cache --update \
            'su-exec==0.2-r2' \
            'tini==0.19.0-r1' \
 && chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT [ "tini" , "/usr/local/bin/docker-entrypoint" ]

CMD [ "sh" ]
