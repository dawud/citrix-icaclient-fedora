% ICA (1) Container Image Pages
% David Sastre Medina <d.sastre.medina@gmail.com>
% August 12, 2017

# NAME

Citrix Receiver \- Citrix Receiver is the easy-to-install client software that
provides access to your XenDesktop and XenApp installations.

# DESCRIPTION

Receiver for Linux enables users to access virtual desktops
and hosted applications delivered by XenDesktop and XenApp from devices
running the Linux operating system.

The citrix-icaclient image is designed to be run by the atomic command with one of these options:

`run`

Starts the installed container with selected privileges to the host.

`stop`

Stops the installed container

The container itself consists of:

    \- Fedora 26 base image
    \- Atomic help file
    \- OpenSSH server
    \- Citrix Receiver

Files added to the container during docker build include:

    \- help.1
    \- the Dockerfile itself
    \- wfclient.ini

# "USAGE"
To use the citrix-receiver container, you can run the atomic command with run or stop options:

To run the citrix-receiver container:

  `atomic run citrix-receiver`

To stop the citrix-receiver container:

  `atomic stop citrix-receiver`

# LABELS
The citrix-receiver container includes the following Atomic LABEL settings:
that `atomic` command can leverage:

`RUN`

  LABEL run="docker run -d -p 22:22 --name \${NAME} \
            -v /etc/machine-id:/etc/machine-id:ro \
            -v /etc/localtime:/etc/localtime:ro \
            -e IMAGE=IMAGE -e NAME=NAME \${IMAGE}"

  The contents of the RUN label tells an `atomic run citrix-icaclient` command to open port 22 and set the name of the container.

`STOP`

  LABEL stop="docker stop \${NAME}"

# HISTORY

TBC
