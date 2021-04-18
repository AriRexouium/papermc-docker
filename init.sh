#!/bin/bash

# Enter server directory.
cd minecraft

# Handle Minecraft Version Validation #########################################
# Fetch latest version of Minecraft if version isn't specified.
urlPrefix="https://papermc.io/api/v2/projects/paper"
if [ ${MINECRAFT_VERSION} = latest ]; then
  MINECRAFT_VERSION="$(wget -qO - ${urlPrefix} | jq -r '.versions[-1]')"

# Check to verify that supplied version number is valid.
elif [ $(wget -qO - ${urlPrefix} | jq ".versions | index(\"${MINECRAFT_VERSION}\")") = null ]; then
  echo "${MINECRAFT_VERSION} is not a valid Minecraft version."
  exit 1
fi

# Handle PaperMC Build Validation #############################################
# Fetch latest version of PaperMC if version isn't specified.
urlPrefix="${urlPrefix}/versions/${MINECRAFT_VERSION}"
if [ ${PAPER_BUILD} = latest ]; then
  PAPER_BUILD="$(wget -qO - ${urlPrefix} | jq '.builds[-1]')"

# Check to verify that supplied build number is valid.
elif [ $(wget -qO - ${urlPrefix} | jq ".builds | index(${PAPER_BUILD})") = null ]; then
  echo "${PAPER_BUILD} is not a valid PaperMC build for Minecraft version ${MINECRAFT_VERSION}."
  exit 1
fi

# Handle Installation & Updating ##############################################
jarFile="paper-${MINECRAFT_VERSION}-${PAPER_BUILD}.jar"
# Check to see if the specified jar file exists.
# If it doesn't exist delete all old jar files and download specified version.
if [ ! -e ${jarFile} ]; then
  rm -rf paper-*-*.jar
  wget "${urlPrefix}/builds/${PAPER_BUILD}/downloads/${jarFile}"
fi

# Handle eula.txt File ########################################################
# If the eula confirmation doesn't exist, start the server to
# generate it and then accept the eula after the server has closed.
if [ ! -e eula.txt ]; then
  java -jar ${jarFile} --nogui
  sed -i 's/false/true/g' eula.txt
fi

# Handle Startup, Restart, Shutdown, and Crashes###############################
# Explaination:

# Startup:
# The `.start-server` file is created which jump-starts the script below.

# Restart:
# When the server restarts, it automatically calls `start.sh` which creates
# the `.start-server` file, this allows this script to know to restart the server.

# Shutdown:
# When the server shutsdown, the `.start-server` file does not exist causing
# this init script to simply close allowing the Docker container to close.

# Crash:
# When the server crashes, it checks to see if the environment variable
# `RESTART_ON_CRASH` is set to true and that the exit code is non-zero, then
# it restarts the server.

touch ../.start-server

while [ -e ../.start-server ]; do
  rm ../.start-server
  java -server -Xms${MIN_MEMORY} -Xmx${MAX_MEMORY} ${JAVA_ARGS} -jar ${jarFile} --nogui
  exitCode=$?
  if [ ${RESTART_ON_CRASH} = true ] && [ ! ${exitCode} = 0 ]; then
    touch ../.start-server
  fi
  echo "Minecraft clossed with an exit code of ${exitCode}."
done
