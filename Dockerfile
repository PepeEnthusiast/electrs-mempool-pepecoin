FROM debian:bookworm-slim AS base

ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

RUN apt update -qy && \
    apt install -qy librocksdb-dev curl

FROM base AS build

RUN apt install -qy git clang cmake

ENV RUSTUP_HOME=/rust
ENV CARGO_HOME=/cargo 
ENV PATH=/cargo/bin:/rust/bin:$PATH

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

WORKDIR /build
COPY . .

RUN cargo build --release --bin electrs

FROM base AS deploy

RUN apt update -qy && apt install -qy nginx && rm -rf /var/lib/apt/lists/*

COPY --from=build /build/target/release/electrs /usr/bin/electrs

COPY nginx.conf /etc/nginx/conf.d/electrs.conf

RUN rm /etc/nginx/sites-enabled/default

COPY docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 3000

EXPOSE 50001

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]