# Ignition Architectures with Docker Compose

![Ignition 8.1.37](https://img.shields.io/badge/ignition-8.1.37-brightgreen.svg?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAEt2lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4KPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNS41LjAiPgogPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iCiAgICB4bWxuczpleGlmPSJodHRwOi8vbnMuYWRvYmUuY29tL2V4aWYvMS4wLyIKICAgIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIKICAgIHhtbG5zOnhtcD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLyIKICAgIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIgogICAgeG1sbnM6c3RFdnQ9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZUV2ZW50IyIKICAgdGlmZjpJbWFnZUxlbmd0aD0iNDgiCiAgIHRpZmY6SW1hZ2VXaWR0aD0iNDgiCiAgIHRpZmY6UmVzb2x1dGlvblVuaXQ9IjIiCiAgIHRpZmY6WFJlc29sdXRpb249IjcyLjAiCiAgIHRpZmY6WVJlc29sdXRpb249IjcyLjAiCiAgIGV4aWY6UGl4ZWxYRGltZW5zaW9uPSI0OCIKICAgZXhpZjpQaXhlbFlEaW1lbnNpb249IjQ4IgogICBleGlmOkNvbG9yU3BhY2U9IjEiCiAgIHBob3Rvc2hvcDpDb2xvck1vZGU9IjMiCiAgIHBob3Rvc2hvcDpJQ0NQcm9maWxlPSJzUkdCIElFQzYxOTY2LTIuMSIKICAgeG1wOk1vZGlmeURhdGU9IjIwMjAtMTEt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)

Inductive Automation's Ignition [Architectures](https://inductiveautomation.com/ignition/architectures) implemented with Docker Compose.

- [Ignition Standard Architecture](standard) - Single Gateway and Database
- [Ignition Scale-Out Architecture](scale-out) - 2 Backend and 1 Frontend Gateway
- [Ignition Hub & Spoke Architecture](hub-spoke) - Central and Remote Site Gateways w/ site-local Database.
- [Ignition Enterprise Architecture](enterprise) - Central and Remote Site Gateways with EAM Configuration and site-local Database.
- [Ignition IIoT Architecture](iiot) - Central and Remote Site Gateways with MQTT/Sparkplug Transport.

> [!WARNING]
> **These architecture stacks are for demonstration purposes only.  Production deployments should be using SSL/TLS for Gateway Web UI and Gateway Network connections!**

## Prerequisites

To launch these architecture examples, you'll need to have Docker Engine and Docker Compose installed.  These are available as part of [Docker Desktop](https://www.docker.com/products/docker-desktop).  You can also install [Docker Engine](https://docs.docker.com/engine/install/) directly on Linux and follow up with [Compose V2 CLI plugin](https://docs.docker.com/compose/cli-command/#install-on-linux).

Once you've got Docker ready to go, click one of the architecture links up top to get started!

## Common Configuration

Each of the Compose solutions in this repository leverage some common configurability.

- `.env` file - This contains some environment variables that will be loaded in by Docker Compose.  Variables such as `COMPOSE_PROFILES` can be used to enable some optional functionality (such as redundancy) in the solution.  Additionally, global settings such as the `IGNITION_VERSION` for the image tag can be defined here.

- `docker-compose.yml` - This is the YAML file that defines the containers and associated configuration for the architecture.

- `secrets` folder - **⚠️ WARNING: These secrets exist in-repo for demo purposes only.  Never commit your secrets to source control!** This folder contains secrets that are mapped into a given container and used for setting up credentials.  The files here are referenced within the `secrets:` keys of the `docker-compose.yml`.  Note that the gateway admin password of `password` can be updated by uncommenting the `GATEWAY_ADMIN_*` environment variables in `gw-init/gateway.env` prior to bringing up a given architecture solution.

- `gw-init` folder - This folder contains seed files for the solution that are sourced from the `docker-compose.yml` file.  Items such as gateway backups, gateway network keystores/identifiers, and environment files are used when launching the solution.

- `gw-backup` folder - Sub-folders under here may be bind-mounted into the various containers and used as the target for scheduled gateway backups.

- `gw-build` folder - If this folder is present, it is used to build a derived image as part of the solution.  Custom functionality such as third-party module bundling can be layered onto the base `inductiveautomation/ignition` image.  The derived image is then automatically used to launch containers in the solution.

- `sql-init` folder - Many database containers allow some pre-configuration scripts to be executed on first-launch.  If this folder is present, the database server container may stage schemas/users on startup to provide the required configuration for the connected gateways.
