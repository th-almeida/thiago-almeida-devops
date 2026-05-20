#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/rendered"
VARIABLES_FILE="${ROOT_DIR}/config/variables.env"

if [ -f "${VARIABLES_FILE}" ]; then
  set -a
  # shellcheck source=/dev/null
  source "${VARIABLES_FILE}"
  set +a
fi

NAMESPACE="${NAMESPACE:-${K8S_NAMESPACE:-satc-devops}}"
DOCKER_IMAGE="${DOCKER_IMAGE:?Defina DOCKER_IMAGE (ex.: usuario/thiago-almeida-devops:0.0.2)}"
APP_HOST="${APP_HOST:-gremio.local}"

rm -rf "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}/blue-green" "${OUTPUT_DIR}/canary" "${OUTPUT_DIR}/load-test"

render_file() {
  local src="$1"
  local dest="$2"
  sed \
    -e "s|##K8S_NAMESPACE##|${NAMESPACE}|g" \
    -e "s|##DOCKER_IMAGE##|${DOCKER_IMAGE}|g" \
    -e "s|##APP_HOST##|${APP_HOST}|g" \
    "${src}" > "${dest}"
}

for file in "${SCRIPT_DIR}"/*.yaml; do
  [ -f "${file}" ] || continue
  render_file "${file}" "${OUTPUT_DIR}/$(basename "${file}")"
done

for file in "${SCRIPT_DIR}/blue-green"/*.yaml; do
  render_file "${file}" "${OUTPUT_DIR}/blue-green/$(basename "${file}")"
done

for file in "${SCRIPT_DIR}/canary"/*.yaml; do
  render_file "${file}" "${OUTPUT_DIR}/canary/$(basename "${file}")"
done

for file in "${SCRIPT_DIR}/load-test"/*.yaml; do
  render_file "${file}" "${OUTPUT_DIR}/load-test/$(basename "${file}")"
done

echo "Manifests renderizados em ${OUTPUT_DIR}"
echo "  NAMESPACE=${NAMESPACE}"
echo "  DOCKER_IMAGE=${DOCKER_IMAGE}"
echo "  APP_HOST=${APP_HOST}"
