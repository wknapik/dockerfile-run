# What is dockerfile-run?

`dockerfile-run` is a tool that allows Dockerfiles from stdin, local files, or
remote urls to be executed like scripts (with, or without arguments).

It also allows options to be passed to `docker run` both from a
[shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) embedded in the
Dockerfile, and on the command line.

# How do I install it?

Save `dockerfile-run` somewhere in $PATH and make it executable.
The tool requires bash, coreutils, curl (optional, only for remote
dockerfiles), docker and ncurses (optional, will be used if present).

# How does it work?

`dockerfile-run` reads a Dockerfile, builds a docker image from it and executes
a command specified by the user (or the default command) in a container based
on that image.

# How do I use it?

In most cases, `dockerfile-run` accepts a single argument to specify where the
Dockerfile is to be read from:
* The string "-" (stdin)
* A string beginning with "http://", or "https://" (remote dockerfile)
* Any other string (local file path)

Additionally, options [can be passed](#passing-options-do-docker-run) to
`docker run`, from the shebang, or the command line, or both, followed by a
delimeter (`---`).

## Execute local Dockerfile (via [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix))).

`#!/usr/bin/env -S docker-run ---` at the top of a dockerfile does what
`#!/bin/sh`, or `#!/usr/bin/env bash` does at the top of a shell script.

```console
% cat Dockerfile
#!/usr/bin/env -S dockerfile-run ---
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
FROM alpine <-- enter + ctrl+d for EOF
/ #         <-- this is an interactive alpine shell
```

## Execute remote Dockerfile.

```console
% dockerfile-run https://raw.githubusercontent.com/jessfraz/dockerfiles/master/htpasswd/Dockerfile\
    -nbB user password
user:$2y$05$9eM6Ed7Ddsst3BpQFKnY2.PRcGK/Lzt02PntF0yIEH4F5BBWYvgjW

%
```

# Advanced usage

## Environment variables

There are three verbosity levels for the `docker build` stage, controlled by
the environment variable `DFR_VERBOSITY`. `0` for no output, `1` for condensed
output, `2` for full output. The default is `1`.

The `DFR_CONTEXT` variable can be used to force the build context for `docker
build` to a specific location. The default when reading from a local file is
the directory containing the dockerfile, while the default when reading from
stdin or a remote file is the current directory.

## Passing options to `docker run`

Additional options can be passed to `docker run` simply by following them with
the delimeter (`---`) to distinguish them from other options. This applies to
both the shebang and the command line.

_Notice: in the examples below, `env` is used with the
[-S](https://www.gnu.org/software/coreutils/manual/html_node/env-invocation.html#g_t_002dS_002f_002d_002dsplit_002dstring-usage-in-scripts)
option, which allows multiple arguments to be passed._

### Via shebang

#### `htop` running in host pid namespace

```console
% cat ./htop
#!/usr/bin/env -S dockerfile-run --pid=host ---
FROM alpine
RUN apk --no-cache add htop
ENTRYPOINT ["htop"]
% ./htop -t
```

#### `aws-cli` with ~/.aws mounted in the container

```console
% cat ./aws
#!/usr/bin/env -S dockerfile-run -v "${HOME}/.aws:/root/.aws" ---
FROM alpine
RUN apk add --no-cache aws-cli
ENTRYPOINT ["aws"]
% ./aws s3 ls
2021-03-24 00:37:00 bukkit
%
```

### Via command line

FIXME

# How do I remove all images created by dockerile-run?

```shell
docker images -q --no-trunc --filter="label=dockerfile-run"|sort -u|xargs -I{} docker rmi -f "{}"
```

# At the risk of stating the obvious...

Don't execute Dockerfiles from untrusted, or mutable sources.

There's a reason Dockerfiles are not allowed to set `docker run` options
natively. Use this tool at your own risk.
