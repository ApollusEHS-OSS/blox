###############################################################################
# AWSH Workspace - AWSH Toolset with IAC tools
###############################################################################
FROM "hestio/awsh"


###############################################################################
# UUID ARGS to prevent Docker's inheritance from ruining our day
###############################################################################
ARG BLOX_BUILD_HTTP_PROXY
ARG BLOX_BUILD_HTTPS_PROXY
ARG BLOX_BUILD_NO_PROXY

###############################################################################
# ARGs
###############################################################################

ARG DML_BASE_URL_TF="https://releases.hashicorp.com/terraform"
ARG DML_BASE_URL_TFLINT="https://github.com/terraform-linters/tflint/releases/download"
ARG AWSH_PYTHON_DEPS="/tmp/requirements.python2"
ARG RUNTIME_PACKAGES="wget"
ARG DEFAULT_TERRAFORM_VERSION="0.11.3"
ARG DEFAULT_TFLINT_VERSION="0.9.3"
ARG SW_VER_LANDSCAPE="0.3.2"

###############################################################################
# ENVs
###############################################################################
ENV AWSH_ROOT /opt/awsh
ENV AWSH_USER_HOME /home/awsh
ENV AWSH_USER awsh
ENV AWSH_GROUP awsh
ENV PUID 1000
ENV PGID 1000
ENV PYTHONPATH /opt/awsh/lib/python
ENV PATH "/opt/awsh/bin:/opt/awsh/bin/tools:${PATH}:${AWSH_USER_HOME}/bin"

ENV DEFAULT_TERRAFORM_VERSION ${DEFAULT_TERRAFORM_VERSION}

###############################################################################
# LABELs
###############################################################################

USER root

# Add new entrypoint
COPY lib/docker/entrypoint.sh /opt/awsh/lib/docker/entrypoint.sh

# Add Terraform
RUN \
    cd /usr/local/bin && \
    curl -sSL -x "${BLOX_BUILD_HTTPS_PROXY}" -o "terraform_0.12.7_linux_amd64.zip" "https://releases.hashicorp.com/terraform/0.12.7/terraform_0.12.7_linux_amd64.zip"  && \
    unzip "terraform_0.12.7_linux_amd64.zip" && \
    mv terraform "terraform-0.12.7" && \
    rm "terraform_0.12.7_linux_amd64.zip"

# Install TF 0.11.x (11.x release with reasonable backwards compatibility)
RUN \
    cd /usr/local/bin && \
    curl -sSL -x "${BLOX_BUILD_HTTPS_PROXY}" -o "terraform_0.11.3_linux_amd64.zip" "https://releases.hashicorp.com/terraform/0.11.3/terraform_0.11.3_linux_amd64.zip"  && \
    unzip "terraform_0.11.3_linux_amd64.zip" && \
    mv terraform "terraform-0.11.3" && \
    rm "terraform_0.11.3_linux_amd64.zip"

# Install TF 0.11.7 (first 11.x release with provider breaking changes)
RUN \
    cd /usr/local/bin && \
    curl -sSL -x "${BLOX_BUILD_HTTPS_PROXY}" -o "terraform_0.11.7_linux_amd64.zip" "https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip"  && \
    unzip "terraform_0.11.7_linux_amd64.zip" && \
    mv terraform "terraform-0.11.7" && \
    rm "terraform_0.11.7_linux_amd64.zip"

# Add TF-Lint
RUN \
    cd /usr/local/bin && \
    curl -sSL -x "${BLOX_BUILD_HTTPS_PROXY}" -o "tflint_linux_amd64.zip" "${DML_BASE_URL_TFLINT}/v${DEFAULT_TFLINT_VERSION}/tflint_linux_amd64.zip"  && \
    unzip "tflint_linux_amd64.zip" && \
    rm "tflint_linux_amd64.zip"

# Add landscape
RUN http_proxy="${BLOX_BUILD_HTTP_PROXY}" https_proxy="${BLOX_BUILD_HTTP_PROXY}" gem install terraform_landscape --version ${SW_VER_LANDSCAPE} --no-ri --no-rdoc

COPY bin/ "${AWSH_USER_HOME}/bin/"
COPY etc/ "${AWSH_USER_HOME}/etc/"

# Ensure ownership of AWSH paths
RUN \
    chown -c -R ${AWSH_USER}:${AWSH_GROUP} ${AWSH_ROOT} && \
    chown -c -R ${AWSH_USER}:${AWSH_GROUP} ${AWSH_USER_HOME}

WORKDIR ${AWSH_USER_HOME}

ENTRYPOINT ["/opt/awsh/lib/docker/entrypoint.sh"]

CMD ["/bin/bash", "-i"]

USER awsh
# USER ${AWSH_USER}:${AWSH_GROUP}
