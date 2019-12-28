FROM alpine AS get-base

RUN apk add --no-cache curl

FROM get-base AS get-runner

ARG ARCH=amd64
ARG RUNNER_VERSION=1.3.3

RUN curl -fsSL https://github.com/itzg/mc-server-runner/releases/download/${RUNNER_VERSION}/mc-server-runner_${RUNNER_VERSION}_linux_${ARCH}.tar.gz | tar xz

FROM get-base AS get-server

ARG VERSION=1.15.1
ARG BUILD=31

RUN curl -o paperclip.jar https://papermc.io/api/v1/paper/${VERSION}/${BUILD}/download

FROM adoptopenjdk:13-jre-openj9

WORKDIR /opt/minecraft
RUN addgroup --gid 1000 minecraft \
    && adduser --system --shell /bin/false --uid 1000 --ingroup minecraft --home $(pwd) minecraft \
    && mkdir -p bin config defaults overrides plugins server \
    && chown -R minecraft:minecraft $(pwd)
USER minecraft

EXPOSE 25565 25575
VOLUME [ "/opt/minecraft/config", "/opt/minecraft/overrides", "/opt/minecraft/plugins", "/opt/minecraft/server" ]

COPY defaults/ ./defaults/
COPY bin/start-server.sh ./bin/
COPY --from=get-runner /mc-server-runner /usr/bin/
COPY --from=get-server /paperclip.jar ./bin/

CMD [ "bin/start-server.sh" ]
