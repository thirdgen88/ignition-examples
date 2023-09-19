#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

# Global variables
declare -u AUTH_SALT

###############################################################################
# Update an Ignition SQLite Configuration DB with a baseline username/password
# ----------------------------------------------------------------------------
# ref: https://gist.github.com/thirdgen88/c4257bd4c47b6cc7194d1f5e7cbd6444
###############################################################################
function main() {
  if [ ! -f "${SECRET_LOCATION}" ]; then
    echo ""
    return 0  # Silently exit if there is no secret at target path
  elif [ ! -f "${DB_LOCATION}" ]; then
    echo "WARNING: ${DB_FILE} not found, skipping password registration"
    return 0
  fi

  register_password
}

###############################################################################
# Updates the target Config DB with the target username and salted pw hash
###############################################################################
function register_password() {
  local SQLITE3=( sqlite3 "${DB_LOCATION}" ) password_hash password_input

  echo "Registering Admin Password with Configuration DB"

  # Generate Salted PW Hash
  password_input="$(< "${SECRET_LOCATION}")"
  if [[ "${password_input}" =~ ^\[[0-9A-F]{8,}][0-9a-f]{64}$ ]]; then
    debug "Password is already hashed"
    password_hash="${password_input}"
  else
    password_hash=$(generate_salted_hash "$(<"${SECRET_LOCATION}")")
  fi

  # Update INTERNALUSERTABLE
  echo "  Setting default admin user to USERNAME='${GATEWAY_ADMIN_USERNAME}' and PASSWORD='${password_hash}'"
  "${SQLITE3[@]}" "UPDATE INTERNALUSERTABLE SET USERNAME='${GATEWAY_ADMIN_USERNAME}', PASSWORD='${password_hash}' WHERE PROFILEID=1 AND USERID=1"
}

###############################################################################
# Processes password input and translates to salted hash
###############################################################################
function generate_salted_hash() {
  local auth_pwhash auth_pwsalthash auth_password password_input
  password_input="${1}"
  
  debug "auth_salt is ${AUTH_SALT}"
  auth_pwhash=$(printf %s "${password_input}" | sha256sum - | cut -c -64)
  debug "auth_pwhash is ${auth_pwhash}"
  auth_pwsalthash=$(printf %s "${password_input}${AUTH_SALT}" | sha256sum - | cut -c -64)
  debug "auth_pwsalthash is ${auth_pwsalthash}"
  auth_password="[${AUTH_SALT}]${auth_pwsalthash}"

  echo "${auth_password}"
}

###############################################################################
# Outputs to stderr
###############################################################################
function debug() {
  # shellcheck disable=SC2236
  if [ ! -z ${verbose+x} ]; then
    >&2 echo "  DEBUG: $*"
  fi
}

###############################################################################
# Print usage information
###############################################################################
function usage() {
  >&2 echo "Usage: $0 -u <string> -f <path/to/file> -d <path/to/db> [...]"
  >&2 echo "  -u <string>        Gateway Admin Username"
  >&2 echo "  -f <path/to/file>  Path to secret file containing password or salted hash"
  >&2 echo "  -d <path/to/db>    Path to Ignition Configuration DB"
  >&2 echo "  -s <salt method>   Salt method, either 'timestamp' or 'random' (default)"
}

# Argument Processing
while getopts ":hvu:f:d:s:" opt; do
  case "$opt" in
  v)
    verbose=1
    ;;
  u)
    GATEWAY_ADMIN_USERNAME="${OPTARG}"
    ;;
  f)
    SECRET_LOCATION="${OPTARG}"
    ;;
  d)
    DB_LOCATION="${OPTARG}"
    DB_FILE=$(basename "${DB_LOCATION}")
    ;;
  s)
    # Compute AUTH_SALT based on timestamp or random
    case "${OPTARG}" in
      timestamp)
        AUTH_SALT=$(date +%s | sha256sum | head -c 8)
        ;;
      random)
        # no-op, default will be set below
        ;;
      *)
        usage
        echo "Invalid salt method: ${OPTARG}" >&2
        exit 1
        ;;
    esac
    ;;
  h)
    usage
    exit 0
    ;;
  \?)
    usage
    echo "Invalid option: -${OPTARG}" >&2
    exit 1
    ;;
  :)
    usage
    echo "Invalid option: -${OPTARG} requires an argument" >&2
    exit 1
    ;;
  esac
done

# shift positional args based on number consumed by getopts
shift $((OPTIND-1))

# Check for required defaults
if [ -z "${GATEWAY_ADMIN_USERNAME:-}" ] || [ -z "${SECRET_LOCATION:-}" ] || [ -z "${DB_LOCATION:-}" ]; then
  usage
  exit 1
fi

# set defaults for unset optional args
if [[ -z ${AUTH_SALT+x} ]]; then
  AUTH_SALT=$(od -An -v -t x1 -N 4 /dev/random | tr -d ' ')
fi

main
