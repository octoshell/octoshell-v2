#!/bin/sh

TOKEN="$OCTOSHELL_CONTROL_TOKEN"
if [ x$TOKEN = x ]; then
  TOKEN=octo_secret_tonek
fi

curl http://localhost:7000/stats?token=$TOKEN
echo

