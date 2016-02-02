FROM debian:jessie
MAINTAINER David Personette <dperson@dperson.com>

#ENV HOME="/root" LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"
#apt-get install -qqy --no-install-recommends mono-runtime mediainfo \
#            libc6-dev libsqlite3-dev ffmpeg imagemagick-6.q8 \
#            libmagickwand-6.q8-2 libmagickcore-6.q8-2 emby-server \

# Install emby
RUN export DEBIAN_FRONTEND='noninteractive' && \
    url='http://download.opensuse.org/repositories/home:emby/Debian_8.0' && \
    echo 'deb http://www.deb-multimedia.org jessie main non-free' \
                >>/etc/apt/sources.list && \
    echo 'deb http://www.deb-multimedia.org jessie-backports main' \
                >>/etc/apt/sources.list && \
    apt-get update -qq && \
    apt-get install -qqy --force-yes --no-install-recommends curl \
                deb-multimedia-keyring && \
    curl -Ls "$url/Release.key" | apt-key add - && \
    echo "deb $url/ /" >>/etc/apt/sources.list.d/emby-server.list && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends emby-server ffmpeg imagemagick\
                mediainfo \
                $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') &&\
    mkdir -p /config /media && \
    chown -Rh emby. /config /media && \
    apt-get purge -qqy curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/cache/* /var/tmp/*

COPY emby.sh /usr/bin/

VOLUME ["/config", "/media"]

EXPOSE 8096 8920 7359/udp 1900/udp

ENTRYPOINT ["emby.sh"]