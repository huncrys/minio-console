FROM golang:1.24-alpine AS build

ARG TARGETOS
ARG TARGETARCH

ENV GOOS=${TARGETOS} \
    GOARCH=${TARGETARCH} \
    CGO_ENABLED=0 \
    GO111MODULE=on

WORKDIR /build

# Install curl
RUN apk add -U --no-cache ca-certificates && \
    apk add -U --no-cache curl && \
    apk add -U --no-cache bash

COPY dockerscripts/download-static-curl.sh /build/download-static-curl
RUN chmod +x /build/download-static-curl && \
    /build/download-static-curl

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -trimpath --tags=kqueue --ldflags "-s -w" -o /go/bin/console ./cmd/console

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
