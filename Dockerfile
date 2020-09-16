ARG VERSION=v0.8.5

FROM debian:buster-slim AS builder

ARG VERSION

WORKDIR /build

RUN apt-get update
RUN apt-get install -y git rustc clang cmake libsnappy-dev

RUN git clone --branch $VERSION https://github.com/romanz/electrs .

RUN cargo build --release --bin electrs

FROM debian:buster-slim

COPY --from=builder /build/target/release/electrs /bin/electrs

# Electrum RPC
EXPOSE 50001

# Prometheus monitoring
EXPOSE 4224

STOPSIGNAL SIGINT

ENTRYPOINT electrs
