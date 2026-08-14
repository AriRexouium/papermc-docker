
# Set & Fetch Java
FROM alpine:latest AS download-temurin

ARG JAVA_VERSION="25"
ENV JAVA_HOME="/opt/java/openjdk"
ENV PATH="$JAVA_HOME/bin:$PATH"

# https://adoptium.net/installation/ci-scripts
RUN \
  cd ~; \
  apk -U upgrade --no-cache; \
  apk add --no-cache curl gnupg; \
  #
  API_URL="https://api.adoptium.net/v3/binary/latest/$JAVA_VERSION/ga/alpine-linux/$(apk --print-arch)/jre/hotspot/normal/eclipse"; \
  FETCH_URL=$(curl -w "%{redirect_url}" "$API_URL"); \
  echo "$API_URL\n$FETCH_URL"; \
  #
  FILENAME=$(curl -LOw %{filename_effective} "$FETCH_URL"); \
  echo "$FILENAME"; \
  curl -L "$FETCH_URL.sha256.txt" | sha256sum -c; \
  #
  gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 3B04D753C9050D9A5D343F39843C48A565F8F04B; \
  curl -LO "$FETCH_URL.sig"; \
  gpg --batch --verify "$FILENAME.sig" "$FILENAME"; \
  #
  mkdir -p "$JAVA_HOME"; \
  tar -xf "$FILENAME" -C "$JAVA_HOME" --strip-components=1 --no-same-owner; \
  java -version

########################################################################################################################

FROM alpine:latest AS build-environment

# Set Environment Variables
# Default Java args are from Aikar. https://mcflags.emc.gs
ENV \
  MINECRAFT_VERSION="latest" \
  PAPER_BUILD="latest" \
  MIN_MEMORY="512M" \
  MAX_MEMORY="1G" \
  RESTART_ON_CRASH="true" \
  JAVA_HOME="/opt/java/openjdk" \
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

# Upgrade System and Install Dependencies
# Since Alpine comes with Busybox, wget is not needed
# since Busybox has its own version of wget.
# Also setup paper user.
RUN \
  apk -U upgrade --no-cache; \
  apk add --no-cache jq tini; \
  adduser -D paper paper

# Post Project Setup
# Switch to paper user, move to home directory, and create server directory.
# Copy files last to help with caching since they change the most.
USER paper
WORKDIR /home/paper
RUN mkdir minecraft
COPY --from=download-temurin $JAVA_HOME $JAVA_HOME
COPY src/* ./

# Container Setup
ENTRYPOINT ["tini", "--"]
CMD ["sh", "init.sh"]
VOLUME /home/paper/minecraft
EXPOSE 25565/tcp
