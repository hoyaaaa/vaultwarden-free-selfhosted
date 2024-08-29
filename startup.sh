#!/bin/bash

# gcloud 인증
gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}

# 버킷 마운트
BUCKET_NAME="vaultwarden-hoya"
MOUNT_POINT="/data"

mkdir -p ${MOUNT_POINT}
gcsfuse ${BUCKET_NAME} ${MOUNT_POINT}

exec "$@"
