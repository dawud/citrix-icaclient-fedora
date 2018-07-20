# Citrix ICA client on Fedora

This container image will allow you to use a [Citrix Receiver](https://www.citrix.com/downloads/citrix-receiver/)
on a Firefox browser in a Fedora container over an SSH connection.

To build the container, run:

```
$ git clone https://github.com/dawud/citrix-icaclient-fedora.git

$ cd citrix-icaclient-fedora-26

$ sudo buildah bud \
    --build-arg=BYOD=https://byod.foo.com/ \
    --label=build-date=$(date -Ins) \
    --label=release-date=$(date -Ins) \
    --label=vcs-ref=$(git rev-parse HEAD) \
    --tag="multicats/citrix-icaclient-fedora:13.10.0.20-0" \
    --tag="multicats/citrix-icaclient-fedora:latest" .
```

Once built, the container can be run using `podman`:

```
$ sudo podman run -d -p 22:22 \
          --name "multicats/citrix-icaclient-fedora:latest" \
          -v /etc/machine-id:/etc/machine-id:ro \
          -v /etc/localtime:/etc/localtime:ro \
          -e IMAGE="multicats/citrix-icaclient-fedora:latest" \
          -e NAME="multicats/citrix-icaclient-fedora:latest" \
          multicats/citrix-icaclient-fedora:latest
```

then use SSH to start a browser:

```
$ ssh \
  -o GSSAPIAuthentication=no \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -X app@$(podman inspect --format '{{ .NetworkSettings.IPAddress  }}' \
           citrix-icaclient-fedora)
```
