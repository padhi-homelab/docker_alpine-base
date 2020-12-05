#!/bin/sh

export ENTRYPOINT_D="${ENTRYPOINT_D:-/etc/docker-entrypoint.d}"
export ENTRYPOINT_LOG_THRESHOLD="${ENTRYPOINT_LOG_THRESHOLD:-1}"
export ENTRYPOINT_RUN_AS_ROOT="${ENTRYPOINT_RUN_AS_ROOT:-}"
export ENTRYPOINT_SKIP_CONFIG="${ENTRYPOINT_SKIP_CONFIG:-}"

ENTRYPOINT_LOG_LEVELS="DBUG INFO WARN ERRO"
ENTRYPOINT_NAME="$(basename "$0")"

log () {
    if [ $1 -ge $ENTRYPOINT_LOG_THRESHOLD ]; then
        LOG_LEVEL_NAME=$(echo $ENTRYPOINT_LOG_LEVELS | cut -d\  -f$1)
        echo >&2 "$(date "+%Y-%m-%d %H:%M:%S") $ENTRYPOINT_NAME ($LOG_LEVEL_NAME) $2"
    fi
}

if [ -z "$ENTRYPOINT_RUN_AS_ROOT" ]; then
    export DOCKER_GID=${DOCKER_GID:-23456}
    export DOCKER_UID=${DOCKER_UID:-12345}
    export DOCKER_GROUP=${DOCKER_GROUP:-user}
    export DOCKER_USER=${DOCKER_USER:-user}

    log 2 "Creating new group '$DOCKER_GROUP' with GID = $DOCKER_GID ..."
    addgroup --gid "$DOCKER_GID" \
             --system \
             "$DOCKER_GROUP"
    if [ $? -eq 0 ]; then
        log 1 "  + Group created successfully."
    else
        EXISTING_GID=$(id -g $DOCKER_GROUP)
        log 3 "  * Group already exists! Existing GID = $EXISTING_GID."
        if [ $EXISTING_GID -ne $DOCKER_GID ]; then
            log 4 "  \`- Aborting due to GID mismatch."
            exit 1
        fi
    fi

    log 2 "Creating new user '$DOCKER_USER' with UID = $DOCKER_UID in group '$DOCKER_GROUP' ..."
    adduser --disabled-password \
            --gecos "" \
            --home "/home/$DOCKER_USER" \
            --ingroup "$DOCKER_GROUP" \
            --uid "$DOCKER_UID" \
            "$DOCKER_USER"
    if [ $? -eq 0 ]; then
        log 1 "  + User created successfully."
    else
        EXISTING_UID=$(id -u $DOCKER_USER)
        log 3 "  * User already exists! Existing UID = $(id -u $DOCKER_USER)."
        if [ $EXISTING_UID -ne $DOCKER_UID ]; then
            log 4 "  \`- Aborting due to UID mismatch."
            exit 1
        fi
    fi
fi

if [ -z "$ENTRYPOINT_SKIP_CONFIG" ]; then
    if find "$ENTRYPOINT_D" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
        log 2 "$ENTRYPOINT_D is not empty, attempting to perform configuration."

        log 1 "Looking for shell scripts in $ENTRYPOINT_D ..."
        find "$ENTRYPOINT_D" -follow -type f -print | sort -n | while read -r f; do
            case "$f" in
                *.sh)
                    if [ -x "$f" ]; then
                        log 1 "  + Launching $f ...";
                        "$f"
                    else
                        log 3 "  + Ignoring $f: not executable!";
                    fi
                    ;;
                *)
                    log 3 "  + Ignoring $f: not a '.sh' script."
                    ;;
            esac
        done

        log 2 "Configuration complete."
    else
        log 2 "No files found in $ENTRYPOINT_D, skipping configuration."
    fi
fi

if [ -z "$ENTRYPOINT_RUN_AS_ROOT" ]; then
    export HOME="/home/$USER"
    set -- su-exec user "$@"
fi

log 2 "Ready for start up!"
exec "$@"
