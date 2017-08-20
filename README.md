# Citrix ICA client on Fedora

This container image will allow you to use a [Citrix Receiver](https://www.citrix.com/downloads/citrix-receiver/)
on a Firefox browser in a Fedora container over an SSH connection.

To build the container, run:

```
$ git clone https://github.com/dawud/citrix-icaclient-fedora-26.git

$ cd citrix-icaclient-fedora-26

$ docker build \
    --build-arg=BYOD=https://byod.foo.com/ \
    --label=build-date=$(date -Ins) \
    --label=release-date=$(date -Ins) \
    --label=vcs-ref=$(git rev-parse HEAD) \
    --tag="multicats/citrix-icaclient-fedora-26:13.6.0.10243651" \
    --tag="multicats/citrix-icaclient-fedora-26:latest" .
```

Once built, the container can be run using `docker` or `atomic` commands.
To run a container using `atomic`, run:

```
$ sudo atomic run multicats/citrix-icaclient-fedora-26
```

then use SSH to start a browser:

```
$ ssh \
  -o GSSAPIAuthentication=no \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -X app@$(docker inspect --format '{{ .NetworkSettings.IPAddress  }}' \
  citrix-icaclient-fedora-26')'
```
