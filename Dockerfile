FROM debian
MAINTAINER David Personette <dperson@gmail.com>

# Install emby
RUN export DEBIAN_FRONTEND='noninteractive' && \
    url='http://download.opensuse.org/repositories/home:emby/Debian_9.0' && \
    ffurl='http://johnvansickle.com/ffmpeg/releases' && \
    apt-get update -qq && \
    apt-get install -qqy --allow-unauthenticated --no-install-recommends \
                ca-certificates ca-certificates-mono curl gnupg1 libhx28 \
                locales procps xz-utils \
                $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') &&\
    localedef -c -ien_US -fUTF-8 -A/usr/share/locale/locale.alias en_US.UTF-8&&\
    curl -LSs "$ffurl/ffmpeg-release-64bit-static.tar.xz" -o ffmpeg.txz && \
    tar --strip-components=1 --wildcards -C /bin -xf ffmpeg.txz "*/ffmpeg" && \
    tar --strip-components=1 --wildcards -C /bin -xf ffmpeg.txz "*/ffprobe" && \
    curl -LSs "$url/Release.key" | apt-key add - && \
    echo "deb $url/ /" >>/etc/apt/sources.list.d/emby-server.list && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends emby-server && \
    echo '/usr/lib/emby-server/x86_64-linux-gnu' >/etc/ld.so.conf.d/emby.conf&&\
    ldconfig && \
    mkdir -p /config /media && \
    chown -Rh emby. /config /media && \
    apt-get purge -qqy curl gnupg1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/cache/* /var/tmp/* ffmpeg.txz

COPY emby.sh /usr/bin/

VOLUME ["/config", "/media"]

EXPOSE 8096 8920 7359/udp 1900/udp

ENTRYPOINT ["emby.sh"]