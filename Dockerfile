FROM golang:1.19.0-alpine3.16 AS build-env

WORKDIR /usr/src/app

RUN set -ex \
    && export https_proxy=http://192.168.0.101:1080 && http_proxy=http://192.168.0.101:1080 \
    && apk add make

COPY go.mod go.sum ./

RUN set -ex  \
    && export GOPROXY=https://proxy.golang.com.cn,direct \
    && go mod download && go mod verify \
    && go install github.com/cosmtrek/air@latest

COPY . .

RUN set -ex && go build -tags=jsoniter -o /usr/local/bin/app


FROM scratch AS app

COPY --from=build-env /usr/local/bin/app /usr/local/bin/

CMD ["app"]
