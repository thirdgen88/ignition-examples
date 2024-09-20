# Draw from environment (see .env file) for Ignition version/tag to source from
ARG IGNITION_VERSION=${IGNITION_VERSION}
FROM inductiveautomation/ignition:${IGNITION_VERSION} as prep

# Switch to root user for base image updates
USER root

# Install some prerequisite packages
RUN apt-get update && apt-get install -y wget jq zip unzip sqlite3

ARG SUPPLEMENTAL_AWSINJECTOR_DOWNLOAD_URL="https://files.inductiveautomation.com/third-party/cirrus-link/4.0.24/AWS-Injector-signed.modl"
ARG SUPPLEMENTAL_AWSINJECTOR_DOWNLOAD_SHA256="5aa6ab27829e6dfa67026358553a3e5e5d1b8ec689e5ffaae3cdaddbc9a3c252"
ARG SUPPLEMENTAL_AZUREIOTINJECTOR_DOWNLOAD_URL="https://files.inductiveautomation.com/third-party/cirrus-link/4.0.24/Azure-Injector-signed.modl"
ARG SUPPLEMENTAL_AZUREIOTINJECTOR_DOWNLOAD_SHA256="90cee320d98fa9c1d8c0f3786586c8cd8dd256803e08ed3fcfc772acccdf3dbd"
ARG SUPPLEMENTAL_GCPINJECTOR_DOWNLOAD_URL="https://files.inductiveautomation.com/third-party/cirrus-link/4.0.24/Google-Cloud-Injector-signed.modl"
ARG SUPPLEMENTAL_GCPINJECTOR_DOWNLOAD_SHA256="72078b25fb3c6853d85a76c212fb63a8c1277707666b492f67fb91ea333775b8"
ARG SUPPLEMENTAL_MQTTTRANSMISSION_DOWNLOAD_URL="https://files.inductiveautomation.com/third-party/cirrus-link/4.0.24/MQTT-Transmission-signed.modl"
ARG SUPPLEMENTAL_MQTTTRANSMISSION_DOWNLOAD_SHA256="cb5d620513110c23b618989b56c5c2a67c45c36944a25d127586e8e303f0273a"
ARG SUPPLEMENTAL_MQTTTRANSMISSIONNIGHTLY_DOWNLOAD_URL="https://ignition-modules-nightly.s3.amazonaws.com/Ignition8/MQTT-Transmission-signed.modl"
ARG SUPPLEMENTAL_MQTTTRANSMISSIONNIGHTLY_DOWNLOAD_SHA256="notused"
ARG SUPPLEMENTAL_MQTTENGINE_DOWNLOAD_URL="https://files.inductiveautomation.com/third-party/cirrus-link/4.0.24/MQTT-Engine-signed.modl"
ARG SUPPLEMENTAL_MQTTENGINE_DOWNLOAD_SHA256="ad8924bdfc248fc4cc1d58badc37d0581081995536780edb260ebff8081ebb99"
ARG SUPPLEMENTAL_MQTTENGINENIGHTLY_DOWNLOAD_URL="https://ignition-modules-nightly.s3.amazonaws.com/Ignition8/MQTT-Engine-signed.modl"
ARG SUPPLEMENTAL_MQTTENGINENIGHTLY_DOWNLOAD_SHA256="notused"
ARG SUPPLEMENTAL_MQTTDISTRIBUTOR_DOWNLOAD_URL="https://files.inductiveautomation.com/third-party/cirrus-link/4.0.24/MQTT-Distributor-signed.modl"
ARG SUPPLEMENTAL_MQTTDISTRIBUTOR_DOWNLOAD_SHA256="10c8026b9ccab90d267291de217d07490b4dab0adbf5af8501482f1fa59b27a5"
ARG SUPPLEMENTAL_MQTTDISTRIBUTORNIGHTLY_DOWNLOAD_URL="https://ignition-modules-nightly.s3.amazonaws.com/Ignition8/MQTT-Distributor-signed.modl"
ARG SUPPLEMENTAL_MQTTDISTRIBUTORNIGHTLY_DOWNLOAD_SHA256="notused"
ARG SUPPLEMENTAL_MODULES

# Set working directory for this prep image and ensure that exits from sub-shells bubble up and report an error
WORKDIR /root
SHELL [ "/usr/bin/env", "-S", "bash", "-euo", "pipefail", "-O", "inherit_errexit", "-c" ]

# Retrieve all targeted modules and verify their integrity
COPY --chmod=0755 retrieve-modules.sh .
RUN ./retrieve-modules.sh \
    -m "${SUPPLEMENTAL_MODULES:-}"

# Set CERTIFICATES/EULAS acceptance in gateway backup config db
COPY *.gwbk ./
COPY --chmod=0755 register-module.sh register-password.sh ./
ARG GATEWAY_ADMIN_USERNAME="admin"
ARG BASE_GWBK_NAME="base.gwbk"
RUN --mount=type=secret,id=gateway-admin-password \
    unzip -q "${BASE_GWBK_NAME}" db_backup_sqlite.idb && \
    shopt -s nullglob; \
    for module in *.modl; do \
        ./register-module.sh \
            -f "${module}" \
            -d db_backup_sqlite.idb; \
    done; \
    shopt -u nullglob && \
    ./register-password.sh \
        -u "${GATEWAY_ADMIN_USERNAME}" \
        -f /run/secrets/gateway-admin-password \
        -d db_backup_sqlite.idb && \
    zip -q -f "${BASE_GWBK_NAME}" db_backup_sqlite.idb || \
        if [[ ${ZIP_EXIT_CODE:=$?} == 12 ]]; then \
            echo "No changes to internal database needed during module registration."; \
        else \
            echo "Unknown error (${ZIP_EXIT_CODE}) encountered during re-packaging of config db, exiting." && \
            exit ${ZIP_EXIT_CODE}; \
        fi

# Final Image
FROM inductiveautomation/ignition:${IGNITION_VERSION} as final
ARG BASE_GWBK_NAME="base.gwbk"
ARG IGNITION_EDITION="standard"

# Embed modules and base gwbk from prep image as well as entrypoint shim
COPY --from=prep --chown=ignition:ignition /root/*.modl ${IGNITION_INSTALL_LOCATION}/user-lib/modules/
COPY --from=prep --chown=ignition:ignition /root/${BASE_GWBK_NAME} ${IGNITION_INSTALL_LOCATION}/base.gwbk
COPY --chmod=0755 --chown=root:root docker-entrypoint-shim.sh /usr/local/bin/

# Return to ignition user
USER ignition

# Set Ignition Edition default based on build argument
ENV IGNITION_EDITION="${IGNITION_EDITION}"

# Target the entrypoint shim for any custom logic prior to gateway launch
ENTRYPOINT [ "docker-entrypoint-shim.sh" ]
