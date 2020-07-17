#!/usr/bin/env bash

set -euo pipefail

# Config file for markdownlint
export CONFIG_FILE=${INPUT_CONFIG_FILE:-}

# Debug variable - enable by setting non-empty value
export DEBUG=${INPUT_DEBUG:-}

# Exclude files or directoryes which should not be linted
export EXCLUDE=${INPUT_EXCLUDE:-}

# Command line parameters for fd
export FD_CMD_PARAMS="${INPUT_FD_CMD_PARAMS:- . -0 --extension md --type f --hidden --no-ignore}"

# Set files or paths variable containing markdown files
export SEARCH_PATHS=${INPUT_SEARCH_PATHS:-}

print_error() {
  echo -e "\e[31m*** ERROR: ${1}\e[m"
}

print_info() {
  echo -e "\e[36m*** ${1}\e[m"
}

error_trap() {
  print_error "Something went wrong - see the errors above..."
  exit 1
}

################
# Main
################

trap error_trap ERR

[ -n "${DEBUG}" ] && set -x

IFS=' ' read -r -a FD_CMD_PARAMS <<< "$FD_CMD_PARAMS"

# Change FD_CMD_PARAMS variable only if INPUT_FD_CMD_PARAMS was not defined or is empty
if [ -z "${INPUT_FD_CMD_PARAMS+x}" ] || [ -z "${INPUT_FD_CMD_PARAMS}" ]; then
  if [ -n "${EXCLUDE}" ]; then
    for EXCLUDED in ${EXCLUDE}; do
      FD_CMD_PARAMS+=("--exclude" "${EXCLUDED}")
    done
  fi

  if [ -n "${SEARCH_PATHS}" ]; then
    for SEARCH_PATH in ${SEARCH_PATHS}; do
      FD_CMD_PARAMS+=("${SEARCH_PATH}")
    done
  fi
fi

declare -a MARKDOWNLINT_CMD_PARAMS
if [ -n "${CONFIG_FILE}" ]; then
  MARKDOWNLINT_CMD_PARAMS+=("--config" "${CONFIG_FILE}")
fi

print_info "Start checking..."
print_info "Running: fd ${FD_CMD_PARAMS[*]}"

while IFS= read -r -d '' FILE; do
  print_info "Running: markdownlint ${MARKDOWNLINT_CMD_PARAMS[*]} ${FILE}"
  markdownlint "${MARKDOWNLINT_CMD_PARAMS[@]}" "${FILE}"
done < <(fd "${FD_CMD_PARAMS[@]}")

print_info "Checks completed..."
