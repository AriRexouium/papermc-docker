#!/bin/bash

# Enter server directory.
cd minecraft

# PaperMC API Endpoint
urlPrefix=https://papermc.io/api/v2/projects/paper

# Fetch latest version of Minecraft if version isn't specified.
if [ ${MINECRAFT_VERSION} = latest ]; then
  MINECRAFT_VERSION=$(wget -qO - $urlPrefix | jq -r '.versions[-1]')
fi

# Fetch latest version of PaperMC if version isn't specified.
urlPrefix=${urlPrefix}/versions/${MINECRAFT_VERSION}
if [ ${PAPER_BUILD} = latest ]; then
  PAPER_BUILD=$(wget -qO - $urlPrefix | jq '.builds[-1]')
fi

JAR_NAME=paper-${MINECRAFT_VERSION}-${PAPER_BUILD}.jar
if [ ! -e ${JAR_NAME} ]; then
  rm -rf paper-*.jar
  wget ${urlPrefix}/builds/${PAPER_BUILD}/downloads/${JAR_NAME}
  if [ ! -e eula.txt ]; then
    java -Xms128M -Xmx512M -jar ${JAR_NAME} --nogui
    sed -i 's/false/true/g' eula.txt
  fi
fi

# Start server
exec java -server -Xms${MIN_MEMORY} -Xmx${MAX_MEMORY} ${JAVA_ARGS} -jar ${JAR_NAME} --nogui
