# Draw from environment (see .env file) for Ignition version/tag to source from
ARG IGNITION_VERSION=${IGNITION_VERSION}
FROM inductiveautomation/ignition:${IGNITION_VERSION} as prep

# Switch to root user for base image updates
USER root

# Install some prerequisite packages
RUN apt-get update && apt-get install -y wget jq zip unzip sqlite3

ARG SUPPLEMENTAL_AWSINJECTOR_DOWNLOAD_URL="https://files.inductiveautomation.com/third-party/cirrus-link/4.0.21/AWS-Injector-signed.modl"
ARG SUPPLEMENTAL_AWSINJECTOR_DOWNLOAD_SHA256="387f5a806df6a9cae2cbcd02181f3062ad613516e50b0ca6d2708f63f0eda46c"
ARG SUPPLEMENTAL_AZUREIOTINJECTOR_DOWNLOAD_URL="https://files.inductiveautomation.com/third-party/cirrus-link/4.0.21/Azure-Injector-signed.modl"
ARG SUPPLEMENTAL_AZUREIOTINJECTOR_DOWNLOAD_SHA256="6f42ea9c7966f0907f56c254f4dd85919077db8b321013e26924ed881c82b19f"
ARG SUPPLEMENTAL_GCPINJECTOR_DOWNLOAD_URL="https://files.inductiveautomation.com/third-party/cirrus-link/4.0.21/Google-Cloud-Injector-signed.modl"
ARG SUPPLEMENTAL_GCPINJECTOR_DOWNLOAD_SHA256="5f022db3afa48a2528daaa7d0c3baa9ee7a1bb2bf25f0553b93ba88864342201"
ARG SUPPLEMENTAL_MQTTTRANSMISSION_DOWNLOAD_URL="https://files.inductiveautomation.com/third-party/cirrus-link/4.0.21/MQTT-Transmission-signed.modl"
ARG SUPPLEMENTAL_MQTTTRANSMISSION_DOWNLOAD_SHA256="6daf806339f62fc3383fca377533deeeb28d8693842e23d7dc03ea0082bc0c16"
ARG SUPPLEMENTAL_MQTTTRANSMISSIONNIGHTLY_DOWNLOAD_URL="https://ignition-modules-nightly.s3.amazonaws.com/Ignition8/MQTT-Transmission-signed.modl"
ARG SUPPLEMENTAL_MQTTTRANSMISSIONNIGHTLY_DOWNLOAD_SHA256="notused"
ARG SUPPLEMENTAL_MQTTENGINE_DOWNLOAD_URL="https://files.inductiveautomation.com/third-party/cirrus-link/4.0.21/MQTT-Engine-signed.modl"
ARG SUPPLEMENTAL_MQTTENGINE_DOWNLOAD_SHA256="e4fb06f96da56f3cf97029c3cbd864c1d91e1ba6677b4241a699804bf33b722c"
ARG SUPPLEMENTAL_MQTTENGINENIGHTLY_DOWNLOAD_URL="https://ignition-modules-nightly.s3.amazonaws.com/Ignition8/MQTT-Engine-signed.modl"
ARG SUPPLEMENTAL_MQTTENGINENIGHTLY_DOWNLOAD_SHA256="notused"
ARG SUPPLEMENTAL_MQTTDISTRIBUTOR_DOWNLOAD_URL="https://files.inductiveautomation.com/third-party/cirrus-link/4.0.21/MQTT-Distributor-signed.modl"
ARG SUPPLEMENTAL_MQTTDISTRIBUTOR_DOWNLOAD_SHA256="210c75ab4a7bfaa0d10f8750a497d427904028db6f4fc1a9ba50a8b1fc8936fe"
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
