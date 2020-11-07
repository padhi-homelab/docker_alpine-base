#!/bin/sh -e

log(){
    echo >&3 "[$(date "+%Y-%m-%d %H:%M:%S")] $0: $1"
}

if [ -z "${ENTRYPOINT_QUIET_LOGS:-}" ]; then
    exec 3>&2
else
    exec 3>/dev/null
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
    GID=${GID:-23456}
    UID=${UID:-12345}

    GROUP=${GROUP:-user}
    USER=${USER:-user}

    log "Creating new user '${USER}' with UID = ${UID} in group ${GROUP} (${GID}) ..."
    addgroup --gid "${GID}" \
             --system \
             "${GROUP}" \
      || log "Group already exists."
    adduser --disabled-password \
            --gecos "" \
            --home "/home/${USER}" \
            --ingroup "${GROUP}" \
            --uid "${UID}" \
            "${USER}" \
      && log "User '${USER}' created successfully." \
      || log "User already exists."

    export HOME="/home/${USER}"
    set -- su-exec user "$@"
fi

log "Ready for start up."
exec "$@"