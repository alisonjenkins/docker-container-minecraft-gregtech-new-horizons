FROM --platform=linux/amd64 rust:1-slim AS rconc-builder
RUN apt-get update && apt-get install -y gcc-aarch64-linux-gnu
RUN rustup target add aarch64-unknown-linux-gnu
ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc
RUN cargo install --git https://github.com/klemens/rconc.git --tag v0.1.3 && \
    cp /usr/local/cargo/bin/rconc /rconc_amd64
RUN cargo install --git https://github.com/klemens/rconc.git --tag v0.1.3 --target aarch64-unknown-linux-gnu && \
    cp /usr/local/cargo/bin/rconc /rconc_arm64

FROM public.ecr.aws/amazoncorretto/amazoncorretto:21
ARG PACK_VERSION="2.8.4"
ARG TARGETARCH
RUN curl -L "https://downloads.gtnewhorizons.com/ServerPacks/GT_New_Horizons_${PACK_VERSION}_Server_Java_17-25.zip" -o /tmp/server.zip && \
    yum install -y unzip && \
    mkdir -p /srv/minecraft/ && \
    cd /srv/minecraft/ && \
    unzip /tmp/server.zip && \
    echo "eula=true" > /srv/minecraft/eula.txt && \
    rm /tmp/server.zip && \
    yum remove -y unzip
RUN chmod +x /srv/minecraft/*.sh
ADD .env /srv/minecraft/.env
ADD minecraft_start_script.sh /usr/bin/minecraft_start_script
RUN chmod +x /usr/bin/minecraft_start_script
COPY --from=rconc-builder /rconc_${TARGETARCH} /usr/bin/rconc
ENTRYPOINT [ "/usr/bin/minecraft_start_script" ]
