FROM fedora:28

# https://docs.projectatomic.io/container-best-practices/#_labels
# https://github.com/projectatomic/ContainerApplicationGenericLabels
# https://docs.openshift.org/latest/creating_images/metadata.html
# https://docs.docker.com/engine/userguide/labels-custom-metadata/
# https://speakerdeck.com/garethr/shipping-manifests-bill-of-lading-and-docker-metadata-and-container

# ATOMIC LABELS
#
# 1. STATIC LABELS:
#
LABEL architecture="x86_64" \
      authoritative-source-url="https://registry-console-default.multicats.local" \
      changelog-url="https://github.com/dawud/citrix-icalient-fedora-26/ChangeLog" \
      description="Receiver for Linux enables users to access virtual desktops \
and hosted applications delivered by XenDesktop and XenApp from devices \
running the Linux operating system." \
      distribution-scope="public" \
      docker.dockerfile="/root/buildinfo/Dockerfile_ICA" \
      license="Copyright 1996-2017 Citrix Systems, Inc. All rights reserved. \
Copyright (c) 1986-1997 RSA Security, Inc. All rights reserved." \
      maintainer="David Sastre <d.sastre.medina@gmail.com>" \
      name="multicats/citrix-icaclient-fedora" \
      release="1" \
      summary="Citrix Receiver is the easy-to-install client software that \
provides access to your XenDesktop and XenApp installations." \
      url="https://citrix.com" \
      vcs-type="git" \
      vcs-url="https://github.com/dawud/citrix-icalient-fedora.git" \
      vendor="Citrix" \
      version=13.10.0.20-0
#
# 2. DYNAMIC LABELS:
#
# This labels can be inserted at build time:
#
# `buildah bud \
#     --build-arg=BYOD=https://byod.foo.com/ \
#     --label=build-date=$(date -Ins) \
#     --label=release-date=$(date -Ins) \
#     --label=vcs-ref=$(git rev-parse HEAD) \
#     --tag="multicats/citrix-icaclient-fedora:13.10.0.20-0" \
#     --tag="multicats/citrix-icaclient-fedora:latest" .`
#
# 3. ACTION LABELS:
#
LABEL run="podman run -d -p 22:22 --name \${NAME} \
          -v /etc/machine-id:/etc/machine-id:ro \
          -v /etc/localtime:/etc/localtime:ro \
          -e IMAGE=IMAGE -e NAME=NAME \${IMAGE}"
LABEL stop="podman stop \${NAME}"
#
# OPENSHIFT LABELS
#
LABEL io.k8s.description="Citrix Receiver is the easy-to-install client software that \
provides access to your XenDesktop and XenApp installations." \
      io.k8s.display-name="Citrix Receiver" \
      io.openshift.expose-services="22:22" \
      io.openshift.min-memory="1Gi" \
      io.openshift.min-cpu="1" \
      io.openshift.non-scalable="true" \
      io.openshift.tags="citrix receiver, xendesktop, xenapp"
#
# VENDOR LABELS
#
LABEL com.citrix.license="Copyright 1996-2017 Citrix Systems, Inc. All rights reserved. \
Copyright (c) 1986-1997 RSA Security, Inc. All rights reserved." \
      com.citrix.name="Citrix Receiver" \
      com.citrix.is-beta="True" \
      com.citrix.is-production="False"
#
# DOCUMENTATION
#
# http://docs.projectatomic.io/container-best-practices/#_creating_a_help_file
COPY help.1 /help.1
# https://docs.projectatomic.io/container-best-practices/#_location_2
RUN mkdir -p /root/buildinfo
COPY Dockerfile /root/buildinfo/Dockerfile_ICA

ENV LANG=C.UTF-8 \
    CITRIX_URL=https://www.citrix.com/downloads/citrix-receiver/linux/receiver-for-linux-latest.html

# Override this variable at build time with an explicit value.
# This labels can be inserted at build time:
# `buildah bud \
#       --build-arg=BYOD="https://mycompany.byod.com" \
#       ....`
ARG BYOD=https://www.duckduckgo.com

# Install the ICA client, Firefox and OpenSSH
RUN DOWNLOAD_URL=$(curl -sL $CITRIX_URL | \
    awk '$0~/<a.*ICAClientWeb-rhel-.*x86_64.rpm/{gsub(/.*rel="/,"https:");gsub(/".*/,"");print $0;exit}'); \
    curl -sSL "$DOWNLOAD_URL" -o icaclient.rpm && \
    dnf install -y -q --nodocs \
      firefox \
      icaclient.rpm \
      openssh-server \
      xdg-utils \
      xorg-x11-xauth && \
    dnf clean all && \
    rm -rf /var/cache/dnf && \
    rm -f /icaclient.rpm && \
    systemctl enable sshd

# Passwordless access to the container, to be used in controlled environments
RUN sed -i 's,^#PermitEmptyPasswords .*,PermitEmptyPasswords yes,' /etc/ssh/sshd_config; \
    sed -i '2iauth sufficient pam_permit.so' /etc/pam.d/sshd

# Add non-root account to run the browser
RUN useradd -ms /home/app/browser.sh app; \
    printf "#!/bin/bash\nfirefox --new-instance $BYOD\n" > /home/app/browser.sh; \
    chmod a+rx /home/app/browser.sh

# Copy default configuration
COPY wfclient.ini /home/app/.ICAClient/wfclient.ini

# Add the OS CA bundle to ICA
RUN pushd /opt/Citrix/ICAClient/keystore/cacerts && \
    awk 'BEGIN {c=0;} /BEGIN CERT/{c++} { print > "cert." c ".pem"}' < /etc/pki/tls/certs/ca-bundle.crt; \
    /opt/Citrix/ICAClient/util/ctx_rehash > /dev/null; \
    cp /opt/Citrix/ICAClient/nls/en.UTF-8/eula.txt /opt/Citrix/ICAClient/nls/en/; \
    install -d -g app -o app -m 0700 /home/app/.config; \
    su -s /bin/sh -c 'xdg-mime default wfica.desktop application/x-ica' app; \
    chown app.app -R /home/app

# Setup systemd
ENV container docker
STOPSIGNAL SIGRTMIN+3
EXPOSE 22
ENTRYPOINT [ "/sbin/init" ]
