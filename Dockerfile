# Fetch Image
# Using alpine over openjdk for a much smaller image.
FROM alpine:latest

# Set Environment Variables
# Default Java args are from Aikar. https://mcflags.emc.gs
ENV \
  MINECRAFT_VERSION="latest" \
  PAPER_BUILD="latest" \
  MIN_MEMORY="512M" \
  MAX_MEMORY="1G" \
  RESTART_ON_CRASH="true" \
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

# Upgrade System and Install Dependencies
# Since Alpine comes with Busybox, wget is not needed
# since Busybox has its own version of wget.
RUN \
  apk update && apk upgrade --no-cache \
  && apk add --no-cache jq openjdk11-jre-headless

# Post Project Setup
# Move to home directory and create server directory.
# Copy files last to help with caching since they change the most.
WORKDIR /home/papermc
RUN mkdir /minecraft
COPY init.sh start.sh ./

# Start Script
CMD ["sh", "init.sh"]

# Volume Setup
VOLUME /home/papermc/minecraft

# Expose Ports
# Minecraft Java uses TCP and not UDP, but opening UDP just in case.
EXPOSE 25565/tcp
EXPOSE 25565/udp
