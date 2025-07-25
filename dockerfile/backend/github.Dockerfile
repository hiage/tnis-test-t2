FROM golang:1.18-alpine as builder

RUN apk update && apk upgrade && \
    apk --no-cache --update add git make 

ENV GO111MODULE=on
ENV GOFLAGS=-mod=vendor

RUN mkdir -p /app
COPY ./backend/* /app

WORKDIR /app

RUN go mod init main
RUN go mod tidy
RUN go mod vendor
RUN go mod verify

RUN go build -o main main.go
RUN rm -rf /var/cache/apk/*

FROM alpine:latest

RUN apk fix && \
    apk add --no-cache \ 
    tzdata \
    curl
    
ENV TZ=Asia/Jakarta

RUN rm -rf /var/cache/apk/*
RUN mkdir -p /app
WORKDIR /app
EXPOSE 8080
COPY --from=builder /app/main /app/
CMD /app/main
