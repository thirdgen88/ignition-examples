FROM mcr.microsoft.com/mssql/server:latest
LABEL maintainer "Kevin Collins <kcollins@purelinux.net>"

# Requires SQLCMDPASSWORD environment variable to be set
HEALTHCHECK \
    --interval=30s \
    --retries=3 \
    --start-period=5s \
    --timeout=30s \
    CMD SQLCMDPASSWORD=${SA_PASSWORD} sh -c '/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -l 3 -t 3 -V 16 -Q "SELECT 1"'

# Setup Entrypoint script
COPY entrypoint.sh /opt/mssql/bin/
ENTRYPOINT [ "/opt/mssql/bin/entrypoint.sh" ]

# Run SQL Server process.
CMD [ "/opt/mssql/bin/sqlservr" ]