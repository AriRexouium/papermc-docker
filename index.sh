#!/bin/bash

# Enter server directory.
cd minecraft

# Handle Minecraft ############################################################
# Fetch latest version of Minecraft if version isn't specified.
urlPrefix="https://papermc.io/api/v2/projects/paper"
if [ ${MINECRAFT_VERSION} = latest ]; then
  MINECRAFT_VERSION="$(wget -qO - ${urlPrefix} | jq -r '.versions[-1]')"

# Check to verify that supplied version number is valid.
elif [ $(wget -qO - ${urlPrefix} | jq ".versions | index(\"${MINECRAFT_VERSION}\")") = null ]; then
  echo "${MINECRAFT_VERSION} is not a valid Minecraft version."
  exit 1
fi

# Handle PaperMC ##############################################################
# Fetch latest version of PaperMC if version isn't specified.
urlPrefix="${urlPrefix}/versions/${MINECRAFT_VERSION}"
if [ ${PAPER_BUILD} = latest ]; then
  PAPER_BUILD="$(wget -qO - ${urlPrefix} | jq '.builds[-1]')"

# Check to verify that supplied build number is valid.
elif [ $(wget -qO - ${urlPrefix} | jq ".builds | index(${PAPER_BUILD})") = null ]; then
  echo "${PAPER_BUILD} is not a valid PaperMC build for Minecraft version ${MINECRAFT_VERSION}."
  exit 1
fi

# Handle Installation and Running #############################################
jarFile="paper-${MINECRAFT_VERSION}-${PAPER_BUILD}.jar"
# Check to see if the specified jar file exists.
# If it doesn't exist delete all old jar files and download specified version.
if [ ! -e ${jarFile} ]; then
  rm -rf paper-*-*.jar
  wget "${urlPrefix}/builds/${PAPER_BUILD}/downloads/${jarFile}"
  # If the eula confirmation doesn't exist, start the server to
  # generate it and then accept the eula after the server has closed.
  if [ ! -e eula.txt ]; then
    java -jar ${jarFile} --nogui
    sed -i 's/false/true/g' eula.txt
  fi
fi

# Start Server
exec java -server -Xms${MIN_MEMORY} -Xmx${MAX_MEMORY} ${JAVA_ARGS} -jar ${jarFile} --nogui
