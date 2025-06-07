FROM --platform=${BUILDPLATFORM} tonistiigi/xx AS xx
FROM --platform=${BUILDPLATFORM} golang:1.24-alpine AS build

WORKDIR /build

COPY --from=xx / /

# Install curl
RUN apk add -U --no-cache ca-certificates && \
    apk add -U --no-cache curl && \
    apk add -U --no-cache bash

COPY dockerscripts/download-static-curl.sh /build/download-static-curl
ARG TARGETARCH
RUN chmod +x /build/download-static-curl && \
    /build/download-static-curl

ENV CGO_ENABLED=0 \
    GO111MODULE=on

COPY go.* .
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go mod download

ARG TARGETPLATFORM
RUN --mount=type=bind,target=. \
    --mount=type=cache,target=/root/.cache \
    --mount=type=cache,target=/go/pkg/mod \
    xx-go --wrap && \
    go build -trimpath --tags=kqueue --ldflags "-s -w" -o /go/bin/console ./cmd/console && \
    xx-verify --static /go/bin/console

FROM registry.access.redhat.com/ubi9/ubi-micro:latest

RUN chmod -R 777 /usr/bin

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /go/bin/console* /usr/bin/
COPY --from=build /go/bin/curl* /usr/bin/

COPY CREDITS /licenses/CREDITS
COPY LICENSE /licenses/LICENSE
COPY dockerscripts/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh

EXPOSE 9090

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
CMD ["console"]
