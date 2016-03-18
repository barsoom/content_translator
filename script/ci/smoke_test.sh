#!/bin/sh
curl -s "$APP_URL/search?query=foo&from=sv&to=en" | grep webtranslateit.com 1> /dev/null || exit 1

