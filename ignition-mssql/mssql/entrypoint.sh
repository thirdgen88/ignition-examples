#!/bin/bash
set -eo pipefail
shopt -s nullglob

MSSQL_BASE=/var/opt/mssql
MSSQL_PROVISIONING_FILE=${MSSQL_BASE}/dbsetup.sql
export SQLCMDPASSWORD=$SA_PASSWORD

# Collect set default values for supported environment variables
MSSQL_DATABASE=${MSSQL_DATABASE:-ignition}
MSSQL_USER=${MSSQL_USER:-ignition}
MSSQL_PASSWORD=${MSSQL_PASSWORD:-ignition}
MSSQL_PID=${MSSQL_PID:-Developer}

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

    # Attach and wait for exit
    wait "$pid"
else
    exec "$@"
fi

