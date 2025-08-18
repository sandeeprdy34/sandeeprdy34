#!/bin/bash

# Usage: ./pod-status.sh -n <namespace>
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
"POD\tTYPE\tCONTAINER\tREADY",
(.items[] as $p
 | ($p.metadata.name) as $pod
 | ($p.status.containerStatuses // [])[]
 | [$pod, "app", .name, (if .ready then "Ready" else "NotReady" end)]
 | @tsv),
(.items[] as $p
 | ($p.metadata.name) as $pod
 | ($p.status.initContainerStatuses // [])[]
 | [$pod, "init", .name, "N/A"]
 | @tsv),
(.items[] as $p
 | ($p.metadata.name) as $pod
 | ($p.status.ephemeralContainerStatuses // [])[]
 | [$pod, "ephemeral", .name, "N/A"]
 | @tsv)
' | column -t
