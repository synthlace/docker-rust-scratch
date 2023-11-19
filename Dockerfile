# syntax=docker/dockerfile:1

ARG RUST_VERSION=1.74.0
ARG APP_NAME=docker-rust-scratch
FROM rust:${RUST_VERSION}-slim-bullseye AS build
ARG APP_NAME
WORKDIR /app

RUN rustup target add x86_64-unknown-linux-musl

RUN --mount=type=bind,source=src,target=src \
    --mount=type=bind,source=Cargo.toml,target=Cargo.toml \
    --mount=type=bind,source=Cargo.lock,target=Cargo.lock \
    --mount=type=cache,target=/app/target/ \
    --mount=type=cache,target=/usr/local/cargo/registry/ \
    <<EOF
set -e
cargo build --target x86_64-unknown-linux-musl --locked --release
cp ./target/x86_64-unknown-linux-musl/release/$APP_NAME /bin/server
EOF

# Minimized scratch image
FROM scratch AS final

COPY --from=build /bin/server /bin/

ENV ROCKET_ADDRESS=0.0.0.0

EXPOSE 8000

CMD ["/bin/server"]
