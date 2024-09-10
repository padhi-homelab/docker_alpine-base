# docker_alpine-base

[![build status](https://img.shields.io/github/actions/workflow/status/padhi-homelab/docker_alpine-base/docker-release-latest.yml?label=BUILD&branch=main&logo=github&logoWidth=24&style=flat-square)](https://github.com/padhi-homelab/docker_alpine-base/actions/workflows/docker-release-latest.yml)
[![testing size](https://img.shields.io/docker/image-size/padhihomelab/alpine-base/testing?label=SIZE%20%5Btesting%5D&logo=docker&logoWidth=24&style=flat-square)](https://hub.docker.com/r/padhihomelab/alpine-base/tags?name=testing)
[![edge size](https://img.shields.io/docker/image-size/padhihomelab/alpine-base/edge?label=SIZE%20%5Bedge%5D&logo=docker&logoWidth=24&style=flat-square)](https://hub.docker.com/r/padhihomelab/alpine-base/tags?name=edge)
[![latest size](https://img.shields.io/docker/image-size/padhihomelab/alpine-base/latest?label=SIZE%20%5Blatest%5D&logo=docker&logoWidth=24&style=flat-square)](https://hub.docker.com/r/padhihomelab/alpine-base/tags?name=latest)

[![latest version](https://img.shields.io/docker/v/padhihomelab/alpine-base/latest?label=LATEST&logo=linux-containers&logoWidth=20&labelColor=darkmagenta&color=gold&style=for-the-badge)](https://hub.docker.com/r/padhihomelab/alpine-base/tags)
[![image pulls](https://img.shields.io/docker/pulls/padhihomelab/alpine-base?label=PULLS&logo=data:image/svg%2bxml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz4KPHN2ZyB3aWR0aD0iODAwcHgiIGhlaWdodD0iODAwcHgiIHZpZXdCb3g9IjAgMCAzMiAzMiIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8ZyBmaWxsPSIjZmZmIj4KICAgIDxwYXRoIGQ9Ik0yMC41ODcsMTQuNjEzLDE4LDE3LjI0NlY5Ljk4QTEuOTc5LDEuOTc5LDAsMCwwLDE2LjAyLDhoLS4wNEExLjk3OSwxLjk3OSwwLDAsMCwxNCw5Ljk4djYuOTYzbC0uMjYtLjA0Mi0yLjI0OC0yLjIyN2EyLjA5MSwyLjA5MSwwLDAsMC0yLjY1Ny0uMjkzQTEuOTczLDEuOTczLDAsMCwwLDguNTgsMTcuNGw2LjA3NCw2LjAxNmEyLjAxNywyLjAxNywwLDAsMCwyLjgzMywwbDUuOTM0LTZhMS45NywxLjk3LDAsMCwwLDAtMi44MDZBMi4wMTYsMi4wMTYsMCwwLDAsMjAuNTg3LDE0LjYxM1oiLz4KICAgIDxwYXRoIGQ9Ik0xNiwwQTE2LDE2LDAsMSwwLDMyLDE2LDE2LDE2LDAsMCwwLDE2LDBabTAsMjhBMTIsMTIsMCwxLDEsMjgsMTYsMTIuMDEzLDEyLjAxMywwLDAsMSwxNiwyOFoiLz4KICA8L2c+Cjwvc3ZnPgo=&logoWidth=20&labelColor=teal&color=gold&style=for-the-badge)](https://hub.docker.com/r/padhihomelab/alpine-base)

---

A tiny multiarch [Alpine Linux] Docker image.

|        386         |       amd64        |       arm/v6       |       arm/v7       |       arm64        |      ppc64le       |       s390x        |       riscv64      |
| :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: |
| :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |


## Features

With only ~50 KB on top of Alpine, this image provides:

- an init system ([tini]) (~30 KB)
- a modular [entrypoint](docker-entrypoint.sh) (~3 KB), and
- automatic privilege lowering (via [su-exec]) (~20 KB).

### Environment Variables

The following environment variables are exposed to control the entrypoint.
They may be set:

- either within a Dockerfile (using the `ENV` statement), and/or
- directly during `docker run` (using the `-e` command-line flag).

#### Controlling privilege lowering:

  - `DOCKER_UID` (default: `"12345"`)
  - `DOCKER_GID` (default: `"23456"`)
  - `DOCKER_USER` (default: `"user"`)
  - `DOCKER_GROUP` (default: `"user"`)

#### Controlling entrypoint behavior:

  - `ENTRYPOINT_D` (default: `"/etc/docker-entrypoint.d"`): Location of configuration scripts
  - `ENTRYPOINT_RUN_AS_ROOT` (default: `""`): If non-empty, _disables privilege lowering!_
  - `ENTRYPOINT_SKIP_CONFIG` (default: `""`): If non-empty, disables running configuration scripts
  - `ENTRYPOINT_LOG_THRESHOLD` (default: `1`): Set the minimum level for log messages to be displayed <br>
    Log levels: `1` (or lower) = debug, `2` = info, `3` = warning, `4` = error, `5` (or greater) = disable

### Configuration Scripts

Additional configuration scripts may be placed in the `ENTRYPOINT_D` directory to be run before the `CMD`.
The entrypoint will execute all executable scripts, i.e. all `.sh` files with the executable (`x`) bit set.
You may:

- either populate these scripts in your Dockerfile (using the `COPY` statement), and/or
- mount them directly during `docker run` (using the `-v` command-line flag).


## Usage

#### Base Image in a Dockerfile

```dockerfile
FROM padhihomelab/alpine-base

# Modify default values for environment variables, if desired
ENV ENTRYPOINT_LOG_THRESHOLD 3

# Install additional configuration scripts, if required
COPY config_scripts/*.sh ${ENTRYPOINT_D}/
RUN chmod +x ${ENTRYPOINT_D}/*.sh

# ... your stuff ...
```

Just make you sure you don't change the entrypoint for the image,
i.e. the `ENTRYPOINT` statement should not appear in your Dockerfile.

#### Running Derived Images

Typically you would want to at least set the `DOCKER_UID` environment variable
when running a container that uses this image.

```console
$ docker run -e DOCKER_UID=`id -u` -i padhihomelab/alpine-base ps aux
2020-11-22 11:27:43 docker-entrypoint (INFO) Creating new group 'user' with GID = 23456 ...
2020-11-22 11:27:43 docker-entrypoint (DBUG)   + Group created successfully.
2020-11-22 11:27:43 docker-entrypoint (INFO) Creating new user 'user' with UID = 1000 in group 'user' ...
2020-11-22 11:27:43 docker-entrypoint (DBUG)   + User created successfully.
2020-11-22 11:27:43 docker-entrypoint (INFO) No files found in /etc/docker-entrypoint.d, skipping configuration.
2020-11-22 11:27:43 docker-entrypoint (INFO) Ready for start up!
PID   USER     TIME  COMMAND
    1 root      0:00 tini /usr/local/bin/docker-entrypoint ps aux
    6 user      0:00 ps aux
```


## FAQ

#### Do I ever need to override the UID, GID etc.? Why are these variables exposed?

Yes, in most cases when you are _writing_ to the host filesystem.
If you are only doing read-only operations, or are not using host volumes,
then you need not worry about setting these variables.

First of all, without privilege lowering, the files written to the host system will be owned by root,
and dealing with them from a non-root account on the host system would be painful.

With privilege lowering, the files written to the host system will be owned by `$DOCKER_UID`,
which may not be identical to the actual UID of the user (on the host system) running the container.
So again, dealing with the newly written files outside of the container will be painful.

For more details, please also see [@vsupalov]'s blog post: "[Avoiding Permission Issues With Docker-Created Files]".

#### What is [tini]? Do I really need it?

tini is an extremely light-weight init system.

Please see "[Why you need an init system]" (by [@Yelp]) for an excellent in-depth discussion.

#### Why not [dumb-init] or another init system? 

The main reason is that tini supports [subreaping] of [Zombie processes], which dumb-init does not.
For concrete examples on why this is an important issue, please see [Hongli Lai]'s excellent blog post:
"[Docker and the PID 1 zombie reaping problem]".

For more details, please also see:
- "[dumb-init or tini]" gist (by [@StevenACoffman])
- "[Why Tini?]" README page (by [@krallin])

#### What is [su-exec]? Do I really need it?

su-exec lowers the privilege from `root` to `$DOCKER_USER` before running the command.
In most cases, you should need it, unless you absolutely do need to run the container as root.

There are several articles on why this is a major security issue. Please see:
- [Docker containers with root privileges] blog post by (Maciej Solnica)
- [Less capabilities, more security: minimize privilege escalation in Docker] blog post (by Itamar Tuerner-Trauring)

#### What about the existing [su]? And [gosu] or [sudo]?

The main reason is that su-exec is significantly smaller than gosu,
and doesn't inherit the quirks of su and sudo.

For more details, please also see:
- [gosu:Why?] and [gosu:Alternatives] README pages (by [@tianon])
- [gosu or su-exec] gist (by [@StevenACoffman])

#### Why not use a supervision suite, like [s6]?

s6 is great.
It actually subsumes both tini and su-exec, and provides many more utilities.

However, it's a little too heavyweight for most of my use cases.
Most of my images run on small SBCs and I try to make them as tiny and lightweight as possible.


[Alpine Linux]: https://alpinelinux.org
[dumb-init]:    https://github.com/Yelp/dumb-init
[gosu]:         https://github.com/tianon/gosu
[s6]:           https://skarnet.org/software/s6/
[su]:           https://man7.org/linux/man-pages/man1/su.1.html
[su-exec]:      https://github.com/ncopa/su-exec
[sudo]:         https://www.sudo.ws/
[tini]:         https://github.com/krallin/tini

[Hongli Lai]:       https://blog.phusion.nl/author/hongli/
[@krallin]:         https://github.com/krallin
[@tianon]:          https://github.com/tianon
[@StevenACoffman]:  https://github.com/StevenACoffman
[@Yelp]:            https://github.com/Yelp
[@vsupalov]:        https://vsupalov.com/

[Avoiding Permission Issues With Docker-Created Files]: https://vsupalov.com/docker-shared-permissions/
[Docker and the PID 1 zombie reaping problem]: https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/
[Docker containers with root privileges]: https://neoteric.eu/blog/docker-containers-with-root-privileges/
[dumb-init or tini]: https://gist.github.com/StevenACoffman/41fee08e8782b411a4a26b9700ad7af5#dumb-init-or-tini
[gosu or su-exec]: https://gist.github.com/StevenACoffman/41fee08e8782b411a4a26b9700ad7af5#gosu-or-su-exec
[gosu:Alternatives]: https://github.com/tianon/gosu#alternatives
[gosu:Why?]: https://github.com/tianon/gosu#why
[Less capabilities, more security: minimize privilege escalation in Docker]: https://pythonspeed.com/articles/root-capabilities-docker-security/
[subreaping]: https://github.com/krallin/tini#subreaping
[Why Tini?]: https://github.com/krallin/tini#why-tini
[Why you need an init system]: https://github.com/Yelp/dumb-init#why-you-need-an-init-system
[Zombie processes]: https://en.wikipedia.org/wiki/Zombie_process
