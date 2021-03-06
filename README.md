# Minecraft Paper Server for Docker

A simple Docker container for running a [Paper][] [Minecraft][] server:

- Mount your configuration, datapacks, or entire existing world as volumes
- Logs only to `STDOUT` for easy collection and less disk activity
- Gracefully shuts down the server when Docker stops the container

## Basic Usage

    docker run --rm -it -e EULA=true \
        -p 25565:25565 -p 25575:25575 \
        -v $(pwd)/config:/opt/minecraft/config \
        -v $(pwd)/overrides:/opt/minecraft/overrides \
        -v $(pwd)/plugins:/opt/minecraft/plugins \
        -v $(pwd)/server:/opt/minecraft/server \
        hannahfamily/mc-server-vanilla

Mounts the `config`, `overrides`, `plugins`, and `server` directories in your
current directory into the container, copies the overrides and default
[configuration][] into the `config` directory, accepts the [Minecraft
EULA][], exposes the server and RCON ports, and starts the server. If a world
exists in the `server` directory, the server will load it; if not, one will
be generated. Your Minecraft client can connect to the server at
`localhost:25565`; others on your local network can connect at `<your local
IP address>:25565`. RCON must be enabled in the server properties file; if
you don't want or need it, you can leave out the `-p 25575:25575` option.

### Stopping the Server

Type `stop` into the server console, or from another terminal:

    docker stop $(docker ps -lq)

(i.e. stop the most recently started Docker container).

## Customization

### Server Configuration

Any configuration files placed in the `overrides` directory that gets mounted
into the container will be read (but not modified) by the server when it
runs. To let the server make changes to the configuration, mount a directory
to `/opt/minecraft/config` instead. Any files not overriden will be copied
from the default [configuration][]. You can use the default configuration for
reference, e.g. if you want to generate a world from a specific seed value.

### Load an Existing World

Likewise, if you have an existing world, just put its data directories (e.g.
`world` if converting from a [vanilla server][], or `world`, `world_nether`,
and `world_the_end` if you have an existing Paper/Spigot server) under the
`server` directory that you mount into the container, and it will be loaded
instead of a new world being generated.

### Plugins

Plugins can be placed in the `plugins` directory that gets mounted into the
container.

### Datapacks

You can place datapacks into `server/world/datapacks` (where `server` is the
directory mounted to `/opt/minecraft/server` in the container), and they will
be loaded by the server. If you're generating a new world, you can create
those directories and place your datapacks, and they won't be erased when the
world is generated.

### Exposing On Custom Ports

If you want to run the server on specific ports (e.g. to run multiple servers
on a single machine), simply change the first number in each `-p` option of the
`docker run` command. For example, to use ports `56001` and `56002`:

    docker run --rm -it -e EULA=true \
        -p 56001:25565 -p 56002:25575 \
        -v $(pwd)/overrides:/opt/minecraft/overrides \
        -v $(pwd)/server:/opt/minecraft/server \
        hannahfamily/mc-server-vanilla

Or to have Docker automatically assign random unused ports, replace both `-p`
arguments with a single `-P`:

    docker run --rm -it -e EULA=true -P \
        -v $(pwd)/overrides:/opt/minecraft/overrides \
        -v $(pwd)/server:/opt/minecraft/server \
        hannahfamily/mc-server-vanilla

and then run `docker ps` in another terminal to see the assigned ports.

**Note:** Changing the port numbers in the `server.properties` file will have
no effect; the startup script always resets `query.port`, `server-port`, and
`rcon.port` before starting the server, so the server process is always
listening on ports 25565 and 25575 within the Docker container. Docker
handles directing traffic from the ports assigned to the container on your
system to the container's internal ports. If you don't want your server to be
available on the default Minecraft ports, use either of the above methods to
change it.

## Environment Variables

### `EULA`

(Default: `false`) Set to `true` to accept the [Minecraft EULA][]. This must
be done explicitly by the server operator, or a file named `eula.txt` with a
line containing only `eula=true` must be in the directory mounted at
`/opt/minecraft/overrides`.

### `HEAP_SIZE`

(Default: `1024`) Amount of memory (in MiB) allocated to the JVM. This value
can be increased depending on server load (players, redstone, &c.) and
available system resources.

### `JVM_OPTS`

Additional options passed to the JVM.

### `RCON_PASSWORD`

(Default: empty string) Sets the password for RCON connections. If set, this
overrides any value set in the `server.properties` file.

### `SERVER_OPTS`

Additional options passed to the Minecraft server.

## Credits

Copyright (c) 2019 Hannah Family. Licensed under the terms of the [MIT
License][].

Paper is licensed under the [GNU General Public License version 3][].

Inspired heavily by [@itzg/docker-minecraft-server][], and uses
[@itzg/mc-server-runner][] to handle graceful shutdown. Default configuration
files are generated by version 1.14.4 of [Minecraft][] Java Edition.
Minecraft © 2009-2019 [Mojang][]. "Minecraft" is a trademark of Mojang
Systems AB.

[@itzg/docker-minecraft-server]: https://github.com/itzg/docker-minecraft-server
[@itzg/mc-server-runner]: https://github.com/itzg/mc-server-runner
[configuration]: config
[gnu general public license version 3]: https://github.com/PaperMC/Paper/blob/ver/1.14/LICENSE.md
[minecraft]: https://www.minecraft.net/
[minecraft eula]: https://account.mojang.com/documents/minecraft_eula
[mit license]: LICENSE
[mojang]: https://mojang.com/
[paper]: https://papermc.io/
