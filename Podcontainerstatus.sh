kubectl get pods -o json \
| jq -r '
"POD\tTYPE\tCONTAINER\tREADY",
(.items[] | . as $p
 | ($p.metadata.name) as $pod
 | ($p.status.containerStatuses // [])[]
 | [$pod, "app", .name, (if .ready then "Ready" else "NotReady" end)]
 | @tsv),
(.items[] | . as $p
 | ($p.metadata.name) as $pod
 | ($p.status.initContainerStatuses // [])[]
 | [$pod, "init", .name, "N/A"]
 | @tsv),
(.items[] | . as $p
 | ($p.metadata.name) as $pod
 | ($p.status.ephemeralContainerStatuses // [])[]
 | [$pod, "ephemeral", .name, "N/A"]
 | @tsv)
' | column -t
