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
ADD minecraft_start_script.sh /usr/bin/minecraft_start_script
RUN chmod +x /usr/bin/minecraft_start_script
COPY rconc_${TARGETARCH} /usr/bin/rconc
ENTRYPOINT [ "/usr/bin/minecraft_start_script" ]
