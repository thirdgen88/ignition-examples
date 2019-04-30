# Ignition Docker Examples

_Updated for Ignition 8!_

This repository will contain some example implementations for the use of [ignition-docker](https://github.com/thirdgen88/ignition-docker).

## Getting Started

To use these examples, you’ll need to have [Docker](https://docs.docker.com/install/) and [Docker Compose](https://docs.docker.com/compose/install/)  installed and working.

Docker Compose allows you to start multiple containers (each container is referred in this context as a "service") and manage them together.  This can really accelerate how to work with Docker containers on a single host.

## Sidecar Examples

The examples below demonstrate how to pair a database with your Ignition container as a [sidecar container](https://docs.microsoft.com/en-us/azure/architecture/patterns/sidecar).

### Ignition and MySQL

See [README](ignition-mysql)

### Ignition and Microsoft SQL Server

See [README](ignition-mssql)

### Ignition and Xvfd (for Mobile Module)

See [README](ignition-mobile)

## Ignition Architecture Examples

These examples show how you can leverage multiple containers (and their inter-communication capabilities) to create multi-gateway architectures with relative ease.

<!-- ### Vision Gateways + Load Balancer -->

<!-- ### Redundant Gateways -->

### Multiple Gateways in Gateway Network

See [README](ignition-gwnetwork)