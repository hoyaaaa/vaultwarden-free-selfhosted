#!/bin/bash

gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}

MOUNT_POINT="/data"

mkdir -p ${MOUNT_POINT}
gcsfuse ${BUCKET_NAME} ${MOUNT_POINT}

exec "$@"
