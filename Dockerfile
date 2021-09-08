ARG VERSION=v0.8.11

FROM rust:1.48.0-slim as builder

ARG VERSION

RUN apt-get update
RUN apt-get install -qq -y clang cmake git
RUN rustup component add rustfmt

# Build, test and install electrs
WORKDIR /build/electrs
RUN git clone --depth=1 --branch $VERSION https://github.com/romanz/electrs .
RUN echo "1.48.0" > rust-toolchain
RUN cargo fmt -- --check
RUN cargo build --locked --release --all
RUN cargo test --locked --release --all
RUN cargo install --locked --path .

FROM debian:buster-slim

RUN adduser --disabled-password --uid 1000 --home /data --gecos "" electrs
USER electrs
WORKDIR /data

COPY --from=builder /usr/local/cargo/bin/electrs /bin/electrs

# Electrum RPC
EXPOSE 50001

# Prometheus monitoring
EXPOSE 4224

STOPSIGNAL SIGINT

ENTRYPOINT ["electrs"]
