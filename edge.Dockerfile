FROM alpine:edge

LABEL maintainer="Saswat Padhi saswat.sourav@gmail.com"

COPY docker-entrypoint.sh \
     /usr/local/bin/docker-entrypoint

RUN apk add --no-cache --update \
        su-exec \
        tini \
 && chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT [ "tini" , "/usr/local/bin/docker-entrypoint" ]

CMD [ "sh" ]
