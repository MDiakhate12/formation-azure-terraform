#!/usr/bin/env bash
# Laisse un verrou orphelin sur le state : un apply est tué pendant qu'il attend la confirmation.
# Sans bash (Windows) : lancez terraform apply, puis fermez brutalement la fenêtre du terminal.
set -euo pipefail
cd "$(dirname "$0")"

terraform apply -var-file=dev.tfvars < <(sleep 600) > /dev/null 2>&1 &
PID=$!
sleep 25
kill -9 "$PID"
echo "Un apply vient d'être interrompu brutalement. Lancez maintenant : terraform plan -var-file=dev.tfvars"
