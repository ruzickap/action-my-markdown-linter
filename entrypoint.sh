#!/usr/bin/env bash

set -Eeuo pipefail

# Config file for markdownlint-cli (it's using .markdownlint.json/.markdownlint.yaml/.markdownlint.yml by default)
CONFIG_FILE=${INPUT_CONFIG_FILE:-}

# Debug variable - enable by setting any value except "false"
DEBUG=${INPUT_DEBUG:-}

# Exclude files or directories which should not be linted
EXCLUDE=${INPUT_EXCLUDE:-}

# Command line parameters for fd ("exclude" and "search_paths" parameters are ignored if this is set)
FD_CMD_PARAMS="${INPUT_FD_CMD_PARAMS:- . --extension md --type f --hidden --exclude .git/}"

# Directories which will be searched for Markdown files
SEARCH_PATHS=${INPUT_SEARCH_PATHS:-}

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

[ "${DEBUG:-false}" != "false" ] && set -x

# Read all lines, not just the first ("read -d ''" returns 1 at the end of input)
read -r -d '' -a FD_CMD_PARAMS <<< "${FD_CMD_PARAMS}" || true

# Change FD_CMD_PARAMS variable only if INPUT_FD_CMD_PARAMS was not defined or is empty
if [ -z "${INPUT_FD_CMD_PARAMS:-}" ]; then
  # No glob expansion: fd must get patterns like "*.md" unchanged
  set -f
  for EXCLUDED in ${EXCLUDE}; do
    FD_CMD_PARAMS+=("--exclude" "${EXCLUDED}")
  done
  set +f

  for SEARCH_PATH in ${SEARCH_PATHS}; do
    # fd only warns about a search path which is not a directory and skips it
    [ -d "${SEARCH_PATH}" ] || {
      print_error "Search path is not a directory: ${SEARCH_PATH}"
      exit 1
    }
    FD_CMD_PARAMS+=("${SEARCH_PATH}")
  done
fi

declare -a MARKDOWNLINT_CMD_PARAMS
if [ -n "${CONFIG_FILE}" ]; then
  MARKDOWNLINT_CMD_PARAMS+=("--config" "${CONFIG_FILE}")
fi

print_info "Start checking..."
print_info "Running: fd ${FD_CMD_PARAMS[*]} --exec-batch markdownlint ${MARKDOWNLINT_CMD_PARAMS[*]}"

# One markdownlint run for all files; fails when fd or markdownlint fails
fd "${FD_CMD_PARAMS[@]}" --exec-batch markdownlint "${MARKDOWNLINT_CMD_PARAMS[@]}"

print_info "Checks completed..."
