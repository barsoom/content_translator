#!/bin/sh
# TODO: Add a real smoke test here, we already check revision elsewhere.
revision=$(git rev-parse HEAD)
curl -s "$APP_URL/revision" | grep $revision 1> /dev/null || exit 1
