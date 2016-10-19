FROM debian:stretch
MAINTAINER David Personette <dperson@gmail.com>

# Install emby
RUN export DEBIAN_FRONTEND='noninteractive' && \
    url='http://download.opensuse.org/repositories/home:emby/Debian_8.0' && \
    echo 'deb http://www.deb-multimedia.org stretch main non-free' \
                >>/etc/apt/sources.list && \
    apt-get update -qq && \
    apt-get install -qqy --allow-unauthenticated --no-install-recommends curl \
                deb-multimedia-keyring ffmpeg gnupg1 mediainfo psutils \
                $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') &&\
    curl -Ls "$url/Release.key" | apt-key add - && \
    echo "deb $url/ /" >>/etc/apt/sources.list.d/emby-server.list && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends emby-server && \
    mkdir -p /config /media && \
    chown -Rh emby. /config /media && \
    apt-get purge -qqy curl gnupg1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/cache/* /var/tmp/*

COPY emby.sh /usr/bin/

VOLUME ["/config", "/media"]

EXPOSE 8096 8920 7359/udp 1900/udp

ENTRYPOINT ["emby.sh"]