ARG VERSION=v0.8.5

FROM rust:1.44.1-slim-buster AS builder

ARG VERSION

WORKDIR /build

RUN apt-get update
RUN apt-get install -y git clang cmake libsnappy-dev

RUN git clone --branch $VERSION https://github.com/romanz/electrs .

RUN cargo build --release --bin electrs

FROM debian:buster-slim

RUN adduser --home /data electrs
USER electrs

COPY --from=builder /build/target/release/electrs /bin/electrs

# Electrum RPC
EXPOSE 50001

# Prometheus monitoring
EXPOSE 4224

STOPSIGNAL SIGINT

ENTRYPOINT electrs
