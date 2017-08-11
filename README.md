# Citrix ICA client on Fedora

This container image will allow you to use a [Citrix Receiver](https://www.citrix.com/downloads/citrix-receiver/)
in a Fedora container over an SSH connection.

The container can be run using `docker` and `atomic` commands.

Once built, you can use:

```
$ sudo atomic run multicats/citrix-icaclient-fedora-26
```

To run a container, then use SSH to start a browser:

```
$ ssh \
  -o GSSAPIAuthentication=no \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -X app@$(docker inspect --format '{{ .NetworkSettings.IPAddress  }}' \
  citrix-icaclient-fedora-26')'
```
