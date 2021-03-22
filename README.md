# What is dockerfile-run?

`dockerfile-run` is a tool that allows Dockerfiles from stdin, local files, or
remote urls to be executed like scripts (with, or without arguments).

# How do I install it?

Save `dockerfile-run` somewhere in $PATH and make it executable.
The tool requires bash, coreutils, curl (only for remote dockerfiles) and
docker.

# How does it work?

`dockerfile-run` reads a Dockerfile, builds a docker image from it and executes
a command specified by the user (or the default command) in a container based
on that image.

# How do I use it?

`dockerfile-run` accepts a single argument to specify where the Dockerfile is
to be read from:
* The string "-" (stdin)
* A string beginning with "http://", or "https://" (remote dockerfile)
* Any other string (local file path)

Some aspects of the tool's operation can be controlled with environment
variables. This is described in more detail in the source code.

## Execute local Dockerfile (via [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix))).

`#!/usr/bin/env docker-run` at the top of a dockerfile does what `#!/bin/sh`,
or `#!/usr/bin/env bash` does at the top of a shell script.

```console
% cat Dockerfile
#!/usr/bin/env dockerfile-run
FROM alpine
% chmod +x Dockerfile
%
```

at this point, the Dockefile can be executed

### Without arguments, executing the default CMD.

```console
% ./Dockerfile
# <-- this is an interactive shell in an alpine container
```
(equivalent to running `dockerfile-run ./Dockerfile`)

### With arguments, executing the supplied CMD.
```console
% ./Dockerfile grep '^NAME' /etc/os-release
NAME="Alpine Linux"
%
```
(equivalent to running `dockerfile-run ./Dockerfile grep '^NAME' /etc/os-release`)

## Execute Dockerfile from stdin.

### Without arguments, executing the default CMD.
```console
% echo -e "FROM alpine\nCMD grep '^NAME' /etc/os-release"|dockerfile-run -
NAME="Alpine Linux"
%
```

### With arguments, executing the supplied CMD.
```console
% echo FROM alpine|dockerfile-run - grep '^NAME' /etc/os-release 
NAME="Alpine Linux"
%
```

### Interactively typing in the Dockerfile.
```console
% dockerfile-run -
FROM alpine <-- ctrl+d for EOF
/ #         <-- this is an interactive alpine shell
```

## Execute remote Dockerfile.

```console
% dockerfile-run https://raw.githubusercontent.com/jessfraz/dockerfiles/master/htpasswd/Dockerfile\
    -nbB user password
user:$2y$05$9eM6Ed7Ddsst3BpQFKnY2.PRcGK/Lzt02PntF0yIEH4F5BBWYvgjW

%
```

# How do I remove all images created by dockerile-run?

```shell
docker images -q --no-trunc --filter="label=dockerfile-run"|xargs -I{} docker rmi "{}"
```
