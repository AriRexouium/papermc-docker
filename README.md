# PaperMC Docker
This creates and initiates a PaperMC Minecraft server inside a Docker container.

This is a dry clone of [Phyremaster/papermc-docker](https://github.com/Phyremaster/papermc-docker) of which this project is based off of.

## Quick Start
```powershell
docker run -tidv $HOME/minecraft:/home/papermc/minecraft -p 25565:25565/tcp --name "PaperMC_Server" aceheliflyer/papermc:latest
```

## Options
| Parameter |                   Suggested                  |                                    Description                                   |
|:---------:|:--------------------------------------------:|:--------------------------------------------------------------------------------:|
|   `-it`   |                      Yes                     |              This creates an interactive terminal to the container.              |
|    `-d`   |                      Yes                     | This detaches the server from the terminal to allow it to run in the background. |
|    `-v`   | `-v $HOME/minecraft:/home/papermc/minecraft` |      This creates a bind mount which stores the server on your host system.      |
|    `-p`   |             `-p 25565:25565/tcp`             |        This exposes the port to allow incoming connections to the server.        |
|  `--name` |           `--name "PaperMC_Server"`          |    The name of the container for the server. This can always be changed later.   |

## Environment Variables
|      Parameter      |            Default            |                         Description                         |
|:-------------------:|:-----------------------------:|:-----------------------------------------------------------:|
| `MINECRAFT_VERSION` |            `latest`           |      The specified version of Minecraft that you want.      |
|    `PAPER_BUILD`    |            `latest`           |        The specified build of PaperMC that you want.        |
|     `MIN_MEMORY`    |             `512M`            |                 The initial starting memory.                |
|     `MAX_MEMORY`    |              `1G`             |    The max amount of memory the server is allowed to use.   |
|  `RESTART_ON_CRASH` |             `true`            |          Should the server restart when it crashes.         |
|     `JAVA_ARGS`     | [View Dockerfile](Dockerfile) | The arguments for Java. By default this uses Aikar's flags. |

## Further Setup

### Enable RCON
Assuming your data is bind-mounted, delete your container with `docker container rm <PaperMC_Server>`.
Re-run the command you used to create your server but add `-p 25575:25575/tcp` to it.
Ideally the first number (the exposed host port) can be set to whatever you want, such as `-p 6789:25565/tcp`.
This also applies if you're trying to add a plugin that requires an open port such as Dynmap or if you simply want to run your server on a port other than 25565.

Example:
```powershell
docker run -tidv $HOME/minecraft:/home/papermc/minecraft -p 25565:25565/tcp -p 25575:25575/tcp --name "PaperMC_Server" aceheliflyer/papermc:latest
```
