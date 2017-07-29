#!/bin/bash
PROC_ID=$1
while kill -0 "$PROC_ID" >/dev/null 2>&1; do
  echo "PROCESS IS RUNNING"
  sleep 1
done
