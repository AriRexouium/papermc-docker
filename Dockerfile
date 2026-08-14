# Grab Azul Zulu Java Docker image
# as the work is already completed for us.
ARG JAVA_VERSION="25"
FROM azul-zulu:${JAVA_VERSION}-jre-headless-alpine AS java-build

# Start creating the production image.
FROM alpine:latest AS prod-build
ARG JAVA_VERSION="25"

# Default Java args are from Aikar. https://mcflags.emc.gs
ENV \
  MINECRAFT_VERSION="latest" \
  PAPER_BUILD="latest" \
  MIN_MEMORY="512M" \
  MAX_MEMORY="1G" \
  RESTART_ON_CRASH="true" \
  JAVA_HOME="/usr/lib/jvm/zulu$JAVA_VERSION" \
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
ENV PATH="$JAVA_HOME/bin:$PATH"

# Add project dependencies. Busybox has own wget module.
# Adding user to avoid root usage.
RUN \
  apk add --no-cache jq tini; \
  adduser -D paper paper

USER paper
WORKDIR /home/paper
RUN mkdir minecraft
COPY --from=java-build $JAVA_HOME $JAVA_HOME
COPY src/* ./

ENTRYPOINT ["tini", "--"]
CMD ["sh", "init.sh"]
VOLUME /home/paper/minecraft
EXPOSE 25565/tcp
