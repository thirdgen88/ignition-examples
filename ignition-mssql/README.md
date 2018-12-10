# Ignition and Microsoft SQL Server

This Docker Compose solution utilizes a custom entrypoint script to initialize a default database for use with Ignition.

## Connecting to the Database from Ignition

With the sidecar container arrangement, the `gateway` container is able to communicate with the `db` container by-name, without any other special configuration.

By default, the database is only reachable by the Ignition container on the network that was created on `docker-compose up`.  You can expose the SQL port `1433` to the outside if you need to connect with SQL Server Management Studio (SSMS), for example.  Just uncomment the `ports` definition.

## Customization

TODO: Fill in details for customizing the initial database configuration and connectivity options.

## Starting the Service