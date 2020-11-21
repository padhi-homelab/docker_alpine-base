#!/bin/sh -e

log(){
    echo >&3 "[$(date "+%Y-%m-%d %H:%M:%S")] $0: $1"
}

if [ -z "${ENTRYPOINT_QUIET_LOGS:-}" ]; then
    exec 3>&2
else
    exec 3>/dev/null
fi

if [ -z "${ENTRYPOINT_RUN_AS_ROOT:-}" ]; then
    export DOCKER_GID=${DOCKER_GID:-23456}
    export DOCKER_UID=${DOCKER_UID:-12345}

    export DOCKER_GROUP=${DOCKER_GROUP:-user}
    export DOCKER_USER=${DOCKER_USER:-user}

    log "Creating new user '${DOCKER_USER}' with UID = ${DOCKER_UID} in group ${DOCKER_GROUP} (${DOCKER_GID}) ..."
    addgroup --gid "${DOCKER_GID}" \
             --system \
             "${DOCKER_GROUP}" \
      || log "Group already exists."
    adduser --disabled-password \
            --gecos "" \
            --home "/home/${DOCKER_USER}" \
            --ingroup "${DOCKER_GROUP}" \
            --uid "${DOCKER_UID}" \
            "${DOCKER_USER}" \
      && log "User '${DOCKER_USER}' created successfully." \
      || log "User already exists."
fi

if [ -z "${ENTRYPOINT_SKIP_CONFIGS:-}" ]; then
    ENTRYPOINT_D="${ENTRYPOINT_D:-/etc/docker-entrypoint.d}"

    if find "${ENTRYPOINT_D}" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
        log "${ENTRYPOINT_D} is not empty, will attempt to perform configuration"

        log "Looking for shell scripts in ${ENTRYPOINT_D}"
        find "${ENTRYPOINT_D}" -follow -type f -print | sort -n | while read -r f; do
            case "$f" in
                *.sh)
                    if [ -x "$f" ]; then
                        log "Launching $f";
                        "$f"
                    else
                        # warn on shell scripts without exec bit
                        log "Ignoring $f, not executable";
                    fi
                    ;;
                *)
                    log "Ignoring $f"
                    ;;
            esac
        done

        log "Configuration complete."
    else
        log "No files found in ${ENTRYPOINT_D}, skipping configuration."
    fi
fi

if [ -z "${ENTRYPOINT_RUN_AS_ROOT:-}" ]; then
    export HOME="/home/${USER}"
    set -- su-exec user "$@"
fi

log "Ready for start up."
exec "$@"