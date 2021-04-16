FROM alpine:latest

# Set Environment Variables
ENV \
  MINECRAFT_VERSION="latest" \
  PAPER_BUILD="latest" \
  MIN_MEMORY="512M" \
  MAX_MEMORY="1G" \
  JAVA_ARGS=" \
    -XX:+UseG1GC \
    -XX:+ParallelRefProcEnabled \
    -XX:MaxGCPauseMillis=200 \
    -XX:+UnlockExperimentalVMOptions \
    -XX:+DisableExplicitGC \
    -XX:+AlwaysPreTouch \
    -XX:G1NewSizePercent=30 \
    -XX:G1MaxNewSizePercent=40 \
    -XX:G1HeapRegionSize=8M \
    -XX:G1ReservePercent=20 \
    -XX:G1HeapWastePercent=5 \
    -XX:G1MixedGCCountTarget=4 \
    -XX:InitiatingHeapOccupancyPercent=15 \
    -XX:G1MixedGCLiveThresholdPercent=90 \
    -XX:G1RSetUpdatingPauseTimePercent=5 \
    -XX:SurvivorRatio=32 \
    -XX:+PerfDisableSharedMem \
    -XX:MaxTenuringThreshold=1 \
    -Dusing.aikars.flags=https://mcflags.emc.gs \
    -Daikars.new.flags=true"

# Upgrade system and install dependencies.
RUN \
  apk update && apk upgrade --no-cache \
  && apk add --no-cache jq wget openjdk11-jre-headless

# Move to directory and copy files.
WORKDIR /home/papermc
RUN mkdir /minecraft
COPY index.sh .

# Start Script
CMD ["sh", "index.sh"]

# Container setup
VOLUME /home/papermc/minecraft
EXPOSE 25565/tcp
EXPOSE 25565/udp
