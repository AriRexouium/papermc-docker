#!/usr/bin/env bash

set -euo pipefail

# TODO:
# Utilize https://fill.papermc.io/v3/projects/paper/versions & https://fill.papermc.io/v3/projects/paper/versions/X/builds/X
# only to save on API calls.

# Enter server directory.
cd minecraft || exit 1

userAgent="papermc-docker (https://github.com/AriRexouium/papermc-docker)"

# Handle Minecraft Version Validation ##########################################
# Fetch latest version of Minecraft if version isn't specified.
urlPrefix="https://fill.papermc.io/v3/projects/paper"
if [ "$MINECRAFT_VERSION" = latest ]; then
  MINECRAFT_VERSION="$(wget -qO - -U "$userAgent" $urlPrefix | jq -r '.versions | to_entries[0] | .value[0]')"

# Check to verify that supplied version number is valid.
elif [ "$(wget -qO - -U "$userAgent" $urlPrefix | jq "[.versions[] | .[]] |index(\"$MINECRAFT_VERSION\")")" = null ]; then
  echo "$MINECRAFT_VERSION is not a valid Minecraft version."
  exit 1
fi

# Handle PaperMC Build Validation ##############################################
# Fetch latest version of PaperMC if version isn't specified.
urlPrefix="$urlPrefix/versions/$MINECRAFT_VERSION"
if [ "$PAPER_BUILD" = latest ]; then
  PAPER_BUILD="$(wget -qO - -U "$userAgent" "$urlPrefix" | jq '.builds[0]')"

# Check to verify that supplied build number is valid.
elif [ "$(wget -qO - -U "$userAgent" "$urlPrefix" | jq ".builds | index($PAPER_BUILD)")" = null ]; then
  echo "$PAPER_BUILD is not a valid PaperMC build for Minecraft version $MINECRAFT_VERSION."
  exit 1
fi

# Handle Installation & Updating ###############################################
jarFile="paper-$MINECRAFT_VERSION-$PAPER_BUILD.jar"
# Check to see if the specified jar file exists.
# If it doesn't exist delete all old jar files and download specified version.
if [ ! -e "$jarFile" ]; then
  rm -rf paper-*-*.jar
  downloadUrl="$(wget -qO - -U "$userAgent" "$urlPrefix/builds/$PAPER_BUILD" | jq -r '.downloads."server:default".url')"
  wget -U "$userAgent" -O "$jarFile" "$downloadUrl"
fi

# Handle eula.txt File #########################################################
# If the eula confirmation doesn't exist, start the server to
# generate it and then accept the eula after the server has closed.
if [ ! -e eula.txt ]; then
  java -jar "$jarFile" --nogui
  sed -i 's/false/true/g' eula.txt
fi

# Handle Startup, Restart, Shutdown, and Crashes ###############################
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

cp ../start.sh .
touch ../.start-server

while [ -e ../.start-server ]; do
  rm ../.start-server
  # shellcheck disable=SC2086
  java -server -Xms"$MIN_MEMORY" -Xmx"$MAX_MEMORY" $JAVA_ARGS -jar "$jarFile" --nogui
  exitCode=$?
  if [ "$RESTART_ON_CRASH" = true ] && [ ! $exitCode = 0 ]; then
    touch ../.start-server
  fi
  echo "Minecraft clossed with an exit code of $exitCode."
done
