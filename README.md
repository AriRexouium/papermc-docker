# PaperMC Docker

[![OpenJDK17 Build](https://img.shields.io/github/actions/workflow/status/arirexouium/papermc-docker/openjdk17.yml?label=OpenJDK17&style=for-the-badge)](https://github.com/AriRexouium/papermc-docker/actions/workflows/openjdk17.yml "OpenJDK17 Build")
[![OpenJDK11 Build](https://img.shields.io/github/actions/workflow/status/arirexouium/papermc-docker/openjdk11.yml?label=OpenJDK11&style=for-the-badge)](https://github.com/AriRexouium/papermc-docker/actions/workflows/openjdk11.yml "OpenJDK11 Build")
[![OpenJDK8 Build](https://img.shields.io/github/actions/workflow/status/arirexouium/papermc-docker/openjdk8.yml?label=OpenJDK8&style=for-the-badge)](https://github.com/AriRexouium/papermc-docker/actions/workflows/openjdk8.yml "OpenJDK8 Build")

[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/aceheliflyer/papermc/latest?style=for-the-badge)](https://hub.docker.com/r/aceheliflyer/papermc/tags?name=latest "Docker Image Size (tag)")
[![Docker Pulls](https://img.shields.io/docker/pulls/aceheliflyer/papermc?style=for-the-badge)](https://hub.docker.com/r/aceheliflyer/papermc "Docker Pulls")
[![GitHub Last Commit](https://img.shields.io/github/last-commit/arirexouium/papermc-docker?style=for-the-badge)](https://github.com/AriRexouium/papermc-docker/commits "GitHub Last Commit")

This creates and initiates a PaperMC Minecraft server inside a Docker container.

*This project is a derivative of [Phyremaster/papermc-docker].*

*This project also uses [Aikar's flags] by default.*

## Quick Start

Here's how to get an extremely basic server up and running.
To attach to the terminal refer to [the following](#attach-to-the-terminal).

```powershell
docker run \
  -tidv $HOME/minecraft:/home/paper/minecraft \
  -p 25565:25565/tcp \
  --name "PaperMC_Server" \
  aceheliflyer/papermc:latest
```

## Options

| Parameter | Suggested | Description |
|:-:|:-:|:-:|
| `-it` | Yes | Creates an interactive terminal to the container. |
| `-d` | Yes | Detaches the server from the terminal to allow it to run in the background. |
| `-v` | `-v $HOME/minecraft:/home/paper/minecraft` | The bind mount or volume where you want to store the server files. |
| `-p` | `-p 25565:25565/tcp` | The exposed port to allow incoming connections to the server. |
| `--name` | `--name "PaperMC_Server"` | The name of the container for the server. This can always be changed later. |

## Environment Variables

| Parameter | Default | Description |
|:-:|:-:|:-:|
| `MINECRAFT_VERSION` | `latest` | The specified version of Minecraft that you want. |
| `PAPER_BUILD` | `latest` | The specified build of PaperMC that you want. |
| `MIN_MEMORY` | `512M` | The initial starting memory. |
| `MAX_MEMORY` | `1G` | The maximum amount of memory the server is allowed to use. |
| `RESTART_ON_CRASH` | `true` | Should the server restart when it crashes. |
| `JAVA_ARGS` | [View Dockerfile] | The arguments for Java. By default this uses [Aikar's flags]. |

## Further Setup & Information

### Attach to the Terminal

To attach to the terminal session on the server,
you can run `docker attach PaperMC_Server`.
Here you can enter all the commands you need just like any other Minecraft server.
To exit the terminal without closing the server,
use the keybind <kbd>Ctrl+P</kbd> & <kbd>Ctrl+Q</kbd>.

If for whatever reason you need to access the shell of the container,
you can use `docker exec -it PaperMC_Server ash`. To exit simply type `exit`
(although if you're accessing the shell, you probably know what you're doing).

### Open More Ports (For RCON, Dynmap, etc.)

For this example, we'll be opening ports for RCON.
Delete your container with `docker container rm PaperMC_Server`.
Your server files will not be deleted since they are saved inside of a volume or a bind-mount depending on what you specified previously.
Re-run the command you used to create your server but add `-p 25575:25575/tcp` to it.
Ideally the first number (the exposed host port) can be set to whatever you want, such as `-p 6789:25565/tcp`.
This also applies if you're trying to add a plugin that requires an open port such
as Dynmap or if you simply want to run your server on a port other than 25565.

Here's an example with open ports for RCON & Dynmap:

```powershell
docker run \
  -tidv $HOME/minecraft:/home/paper/minecraft \
  -p 25565:25565/tcp \ # Default Minecraft Port
  -p 25575:25575/tcp \ # The default RCON Port
  -p 8123:8123/tcp \ # The Default Dynmap Port
  --name "PaperMC_Server" \
  aceheliflyer/papermc:latest
```

## Notable Links

- [GitHub Repository](https://github.com/AriRexouium/papermc-docker "AriRexouium/papermc-docker")
- [Docker Hub Repository](https://hub.docker.com/r/aceheliflyer/papermc "aceheliflyer/papermc")
- [Phyremaster/papermc-docker]
- [Aikar's Flags]

---

<div align="center">
  <a href="https://github.com/AriRexouium/papermc-docker/blob/master/LICENSE.txt" title="License">
    <img src="https://img.shields.io/github/license/arirexouium/papermc-docker?style=for-the-badge" alt="License">
  </a>
</div>

<!-- Links and what not. -->
[Phyremaster/papermc-docker]: <https://github.com/Phyremaster/papermc-docker> (Phyremaster's PaperMC Docker)
[View Dockerfile]: <https://github.com/AriRexouium/papermc-docker/blob/master/Dockerfile#L13-L33> (Dockerfile)
[Aikar's Flags]: <https://mcflags.emc.gs> (Garbage Collector Flags for Minecraft)
