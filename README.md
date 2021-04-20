# PaperMC Docker
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/aceheliflyer/papermc-docker/Deployment?style=for-the-badge)
![Docker Image Size (latest semver)](https://img.shields.io/docker/image-size/aceheliflyer/papermc?style=for-the-badge)
![Docker Pulls](https://img.shields.io/docker/pulls/aceheliflyer/papermc?style=for-the-badge)

This creates and initiates a PaperMC Minecraft server inside a Docker container.

*This project is a derivative of [Phyremaster/papermc-docker].*

*This project also uses [Aikar's flags] by default.*

## Quick Start
Here's how to get an extremely basic server up and running.
It'll automatically handle shutdowns, restarts, and crashes by default.
The server files will be mapped to your home directory in a folder called "minecraft".
```powershell
docker run \
  -tidv $HOME/minecraft:/home/papermc/minecraft \
  -p 25565:25565/tcp \
  --name "PaperMC_Server" \
  aceheliflyer/papermc:latest
```

## Options
| Parameter | Suggested | Description |
|:-:|:-:|:-:|
| `-it` | Yes | Creates an interactive terminal to the container. |
| `-d` | Yes | Detaches the server from the terminal to allow it to run in the background. |
| `-v` | `-v $HOME/minecraft:/home/papermc/minecraft` | The bind mount or volume where you want to store the server files. |
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

### Enable RCON
Assuming your data is bind-mounted, delete your container with `docker container rm PaperMC_Server`.
Re-run the command you used to create your server but add `-p 25575:25575/tcp` to it.
Ideally the first number (the exposed host port) can be set to whatever you want, such as `-p 6789:25565/tcp`.
This also applies if you're trying to add a plugin that requires an open port such
as Dynmap or if you simply want to run your server on a port other than 25565.

Here's an example with open ports for RCON & Dynmap.
```powershell
docker run \
  -tidv $HOME/minecraft:/home/papermc/minecraft \
  -p 25565:25565/tcp \ # Default Minecraft Port
  -p 25575:25575/tcp \ # The default RCON Port
  -p 8123:8123/tcp \ # The Default Dynmap Port
  --name "PaperMC_Server" \
  aceheliflyer/papermc:latest
```

## Notable Links
- [GitHub Repository](https://github.com/Aceheliflyer/papermc-docker "Aceheliflyer/papermc-docker")
- [Docker Hub Repository](https://hub.docker.com/r/aceheliflyer/papermc "aceheliflyer/papermc")
- [Phyremaster/papermc-docker]
- [Aikar's Flags]

---

<div align="center">
  <a href="https://github.com/Aceheliflyer/papermc-docker/blob/master/LICENSE.txt" title="License">
    <img src="https://img.shields.io/github/license/Aceheliflyer/papermc-docker?style=for-the-badge" alt="License">
  </a>
</div>

<!-- Links and what not. -->
[Phyremaster/papermc-docker]: <https://github.com/Phyremaster/papermc-docker> (Phyremaster's PaperMC Docker)
[View Dockerfile]: <https://github.com/Aceheliflyer/papermc-docker/blob/master/Dockerfile#L13-L33> (Dockerfile)
[Aikar's Flags]: <https://mcflags.emc.gs> (Garbage Collector Flags for Minecraft)
