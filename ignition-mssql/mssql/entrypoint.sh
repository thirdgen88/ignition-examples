#!/bin/bash
set -eo pipefail
shopt -s nullglob

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

# usage: process_init_file FILENAME SQLCMD...
#    ie: process_init_file foo.sh sqlcmd -S localhost -u sa
# (process a single initializer file, based on its extension. we define this
# function here, so that initializer scripts (*.sh) can use the same logic,
# potentially recursively, or override the logic used in subsequent calls)
process_init_file() {
	local f="$1"; shift
	local sqlcmd=( "$@" )

	case "$f" in
		*.sh)     echo "$0: running $f"; . "$f" ;;
		*.sql)    echo "$0: running $f"; "${sqlcmd[@]}" -i "$f"; echo ;;
        *.bak)    echo "$0: restoring $f"; "${sqlcmd[@]}" -Q "RESTORE DATABASE [$(basename ${f/.bak/})] FROM DISK='$f'"; echo ;;
		*)        echo "$0: ignoring $f" ;;
	esac
	echo
}

MSSQL_BASE=${MSSQL_BASE:-/var/opt/mssql}
MSSQL_PROVISIONING_FILE=${MSSQL_BASE}/dbsetup.sql
file_env 'SA_PASSWORD' 'ch@nge_m3'
export SQLCMDPASSWORD=$SA_PASSWORD

# Collect set default values for supported environment variables
file_env 'MSSQL_DATABASE' 'test'
file_env 'MSSQL_USER' 'test'
file_env 'MSSQL_PASSWORD' 'test'
file_env 'MSSQL_PID' 'developer'

# Check for Init Complete
if [ ! -f "${MSSQL_BASE}/.docker-init-complete" ]; then
    # Mark Initialization Complete
    touch ${MSSQL_BASE}/.docker-init-complete

    # Initialize MSSQL before attempting database creation
    "$@" &
    pid="$!"

    # Wait up to 60 seconds for database initialization to complete
    echo "Database Startup In Progress"
    for ((i=${MSSQL_STARTUP_DELAY:=60};i>0;i--)); do
        if /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -l 1 -t 1 -V 16 -Q "SELECT 1" &> /dev/null; then
            echo "Database healthy, proceeding with provisioning..."
            break
        fi
        sleep 1
    done
    if [ "$i" -le 0 ]; then
        echo >&2 "Database initialization process failed after ${MSSQL_STARTUP_DELAY} delay."
        exit 1
    fi

    # Stage the new database provisioning steps based on supplied environment variables
    cat << EOF > ${MSSQL_PROVISIONING_FILE}
    CREATE DATABASE [${MSSQL_DATABASE}]
    GO
    USE [${MSSQL_DATABASE}]
    GO
    CREATE LOGIN [${MSSQL_USER}] WITH PASSWORD=N'${MSSQL_PASSWORD}', DEFAULT_DATABASE=[${MSSQL_DATABASE}], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
    GO
    CREATE USER [${MSSQL_USER}] FOR LOGIN [${MSSQL_USER}] WITH DEFAULT_SCHEMA=[dbo]
    GO
    ALTER ROLE [db_owner] ADD MEMBER [${MSSQL_USER}]
EOF

    # Run the provisioning action
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -b -m 16 -V 16 -i ${MSSQL_PROVISIONING_FILE}
    if [ $? -eq 0 ]; then
        echo "Provisioning completed, database [${MSSQL_DATABASE}] created."
        rm ${MSSQL_PROVISIONING_FILE}
    else
        echo >&2 "Failed to provision database."
        exit 1
    fi
    sqlcmd=( sqlcmd -S localhost -U sa -l 3 -t 3 -V 16 )

    echo
    ls /docker-entrypoint-initdb.d/ > /dev/null
    for f in /docker-entrypoint-initdb.d/*; do
        process_init_file "$f" "${sqlcmd[@]}"
    done

    # Attach and wait for exit
    wait "$pid"
else
    exec "$@"
fi

