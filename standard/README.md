# Ignition Standard Architecture

Ignition’s most common architecture consists of a single on-premise Ignition server connected to a SQL database, PLCs, and clients.

![Ignition Standard Architecture Diagram](https://inductiveautomation.com/static/images/architectures/redundant-scada-architecture.a3d7edfbcec6.png)

The standard architecture is best suited for applications that require a scalable, centrally managed SCADA system using only one on-premise Ignition server and select modules. This implementation is the most cost-effective setup since you only pay for one license to have unlimited connections, tags, databases, and web-deployable clients.

## Configure

See [common configuration](../README.md#common-configuration) for specifics on files/folders in this solution.

## Enable

First, make sure your working directory is `standard`:

![Change Working Directory](../assets/standard-change-wd.gif)

To bring up the solution:

    docker-compose up -d

![Bringing up the solution](../assets/standard-compose-up.gif)

## Connect

Once the solution has been launched, you can begin to access the services at:

- Primary Ignition Gateway - http://gateway.localtest.me:8088
- Redundant Ignition Gateway - http://gatewayr.localtest.me:8089 (if redundancy profile was enabled via `COMPOSE_PROFILES` in the `.env` file).
- MariaDB Database - `localhost:3306`

Default admin credentials for Ignition Gateways are `admin` / `password`. Default admin credentials for MariaDB are `root` / `ignition`.

## Monitor

If you'd like to monitor the logs of any of the services, you can use the following:

    docker-compose logs --tail=250 -f <service name>

... where `<service name>` is one of the named services from `docker-compose.yml`, e.g. `gateway` or `db`.  Omit the `<service name>` to start viewing logs from all services.  Use `CTRL-C` to break out of the log view.

## Shutdown

To shutdown the containers within the solution:

    docker-compose down

Note that this will leave data volumes intact on your system so that bringing the solution back online will return to the previous state.  If you want to also remove the data volumes and return the solution to the original state, add a `-v` flag to the *down* command.