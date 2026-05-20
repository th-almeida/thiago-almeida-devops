#!/usr/bin/env bash
# Conecta kubectl ao cluster GKE usando config/variables.env
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=/dev/null
source "${ROOT_DIR}/config/variables.env"

gcloud container clusters get-credentials "${GKE_CLUSTER_NAME}" \
  --zone "${GKE_CLUSTER_LOCATION}" \
  --project "${GCP_PROJECT_ID}"

echo "kubectl apontando para ${GKE_CLUSTER_NAME} (${GKE_CLUSTER_LOCATION})"
kubectl cluster-info
