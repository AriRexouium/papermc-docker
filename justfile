default: build

build:
  docker build -t papermc-docker .

build-nc:
  docker build --no-cache -t papermc-docker .

test:
  act -j dockerImagePublish
