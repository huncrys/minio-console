FROM --platform=${BUILDPLATFORM} tonistiigi/xx:1.6.1@sha256:923441d7c25f1e2eb5789f82d987693c47b8ed987c4ab3b075d6ed2b5d6779a3 AS xx
FROM --platform=${BUILDPLATFORM} goreleaser/goreleaser:v2.9.0@sha256:da5dbdb1fe1c8fa9a73e152070e4a9b178c3500c3db383d8cff2f206b06ef748 AS build

WORKDIR /build

COPY --from=xx / /

# Install curl
RUN apk add -U --no-cache ca-certificates && \
    apk add -U --no-cache curl && \
    apk add -U --no-cache bash

COPY dockerscripts/download-static-curl.sh /tmp/download-static-curl
ARG TARGETARCH
RUN chmod +x /tmp/download-static-curl && \
    /tmp/download-static-curl && \
    rm /tmp/download-static-curl

COPY go.* .
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go mod download

ARG TARGETPLATFORM
ARG CI_COMMIT_TAG
SHELL ["bash", "-c"]
RUN --mount=type=bind,target=.,rw \
    --mount=type=cache,target=/root/.cache \
    --mount=type=cache,target=/go/pkg/mod \
<<EOF
    set -eo pipefail
    args=(
        --skip validate
        --single-target
        --clean
        --output /go/bin/console
    )
    if [ -z "${CI_COMMIT_TAG}" ]; then
        args+=(--snapshot)
    fi
    xx-go --wrap
    set -o allexport
    source "$(go env GOENV)"
    set +o allexport
    goreleaser build "${args[@]}"
    xx-verify --static /go/bin/console
EOF

FROM registry.access.redhat.com/ubi9/ubi-micro:latest

RUN chmod -R 777 /usr/bin

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /go/bin/console /usr/bin/
COPY --from=build /go/bin/curl /usr/bin/

COPY CREDITS /licenses/CREDITS
COPY LICENSE /licenses/LICENSE
COPY dockerscripts/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh

EXPOSE 9090

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
CMD ["console"]
