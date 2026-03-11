#!/bin/bash

set -e

CONFIG="/etc/lab_backup.conf"
BACKUP_ROOT="/backup"
SSH_USER="devops"

echo "Backup started: $(date)"

while read -r HOST IP DIRS; do

    [ -z "$HOST" ] && continue
    [[ "$HOST" =~ ^# ]] && continue

    echo "Backing up $HOST ($IP)"

    HOST_DIR="$BACKUP_ROOT/$HOST"

    mkdir -p "$HOST_DIR"

    # rotate backups
    rm -rf "$HOST_DIR/daily.2"

    [ -d "$HOST_DIR/daily.1" ] && mv "$HOST_DIR/daily.1" "$HOST_DIR/daily.2"
    [ -d "$HOST_DIR/daily.0" ] && mv "$HOST_DIR/daily.0" "$HOST_DIR/daily.1"

    mkdir -p "$HOST_DIR/daily.0"

    for DIR in $DIRS; do

        DEST="$HOST_DIR/daily.0$DIR"
        PREV="$HOST_DIR/daily.1$DIR"

        mkdir -p "$DEST"

        echo "  -> $DIR"

        if [ -d "$PREV" ]; then
            rsync -a \
            --rsync-path="sudo rsync" \
            --link-dest="$PREV" \
            "$SSH_USER@$IP:$DIR/" \
            "$DEST/"
        else
            rsync -a \
            --rsync-path="sudo rsync" \
            "$SSH_USER@$IP:$DIR/" \
            "$DEST/"
        fi

    done

done < "$CONFIG"

echo "Backup finished: $(date)"
