# Copyright (c) 2021 SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM golang:1.16 as requirements

RUN go get -u github.com/google/addlicense

FROM docker.io/library/node:14 as npm-requirements

RUN npm install -g embedme@1.22.0

# hadolint ignore=DL3007
FROM quay.io/sighup/policeman:latest as linter

ENV VALIDATE_KUBERNETES_KUBEVAL="false"

RUN mkdir /app
WORKDIR /app

COPY . .

RUN npm install -g embedme@1.22.0 && /entrypoint.sh && embedme --verify "**/*.md"

FROM golang:1.16 as license

RUN go get -u github.com/google/addlicense

RUN mkdir /app
WORKDIR /app

COPY . .

RUN addlicense -c "SIGHUP s.r.l" -v -l bsd --check .

FROM golang:1.16 as tester

RUN mkdir /app
WORKDIR /app

COPY go.mod go.mod
COPY go.sum go.sum
COPY cmd cmd
COPY pkg pkg
COPY internal internal

RUN go test -v ./... -cover

FROM golang:1.16 as builder

RUN mkdir /app
WORKDIR /app

COPY go.mod go.mod
COPY go.sum go.sum
COPY cmd cmd
COPY pkg pkg
COPY internal internal

WORKDIR /app/cmd/example-check
RUN go build

FROM debian:bullseye as release

COPY --from=builder /app/cmd/example-check/example-check /example-check

RUN groupadd -r SIGHUP && \
    useradd -u 1001 -r -s /bin/false -g SIGHUP cloud && \
    chown cloud:SIGHUP /example-check

USER 1001

ENTRYPOINT ["/example-check"]
