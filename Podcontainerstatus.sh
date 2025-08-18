#!/bin/bash

# Usage: ./pod-ready.sh -n <namespace>
while getopts "n:" opt; do
  case $opt in
    n) NS=$OPTARG ;;
    *) echo "Usage: $0 -n <namespace>" >&2; exit 1 ;;
  esac
done

if [ -z "$NS" ]; then
  echo "Namespace is required. Usage: $0 -n <namespace>"
  exit 1
fi

kubectl get pods -n "$NS" -o json \
| jq -r '
"POD\tCONTAINER\tREADY",
(.items[] as $p
 | ($p.metadata.name) as $pod
 | ($p.status.containerStatuses // [])[]
 | [$pod, .name, (if .ready then "Ready" else "NotReady" end)]
 | @tsv)
' | column -t
