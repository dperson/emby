FROM alpine
MAINTAINER David Personette <dperson@gmail.com>

# Install emby
RUN export LANG=C.UTF-8 && \
    ff_url='http://johnvansickle.com/ffmpeg/releases' && \
    glib_url='https://github.com/sgerrand/alpine-pkg-glibc/releases/download'&&\
    glib_version=2.29-r0 && \
    glibc_base=glibc-${glib_version}.apk && \
    glibc_bin=glibc-bin-${glib_version}.apk && \
    glibc_i18n=glibc-i18n-${glib_version}.apk && \
    monourl='https://archive.archlinux.org/packages/m/mono' && \
    mono_version=5.18.0.240-1 && \
    key=/etc/apk/keys/sgerrand.rsa.pub && \
    url='https://github.com/MediaBrowser/Emby/releases/download' && \
    version=3.5.0.0 && \
    apk --no-cache --no-progress upgrade && \
    apk --no-cache --no-progress add bash curl shadow sqlite-libs tini tzdata&&\
    echo "-----BEGIN PUBLIC KEY-----\
	MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZ2u1KJKUu/fW4A25y9m\
	y70AGEa/J3Wi5ibNVGNn1gT1r0VfgeWd0pUybS4UmcHdiNzxJPgoWQhV2SSW1JYu\
	tOqKZF5QSN6X937PTUpNBjUvLtTQ1ve1fp39uf/lEXPpFpOPL88LKnDBgbh7wkCp\
	m2KzLVGChf83MS0ShL6G9EQIAUxLm99VpgRjwqTQ/KfzGtpke1wqws4au0Ab4qPY\
	KXvMLSPLUp7cfulWvhmZSegr5AdhNw5KNizPqCJT8ZrGvgHypXyiFvvAH5YRtSsc\
	Zvo9GI2e2MaZyo9/lvb+LbLEJZKEQckqRj4P26gmASrZEPStwc+yqy1ShHLA0j6m\
	1QIDAQAB\
	-----END PUBLIC KEY-----" | sed 's/	/\n/g' >$key && \
    curl -LOSs $glib_url/$glib_version/$glibc_base && \
    curl -LOSs $glib_url/$glib_version/$glibc_bin && \
    curl -LOSs $glib_url/$glib_version/$glibc_i18n && \
    apk --no-cache --no-progress add $glibc_base $glibc_bin $glibc_i18n && \
    { /usr/glibc-compat/bin/localedef -c -iPOSIX -fUTF-8 $LANG || :; } && \
    ln -s libsqlite3.so.0 /usr/lib/libsqlite3.so && \
    curl -LSs $monourl/mono-${mono_version}-x86_64.pkg.tar.xz -o mono.txz && \
    tar xf mono.txz && \
    groupadd -r emby && \
    useradd -c 'Emby' -d /usr/lib/emby-server -g emby -m -r emby && \
    echo "Downloading version: $version" && \
    curl -LSs $url/$version/Emby.Mono.zip -o emby.zip && \
    curl -LSs "$ff_url/ffmpeg-release-amd64-static.tar.xz" -o ffmpeg.txz && \
    { tar --strip-components=1 -C /bin -xf ffmpeg.txz "*/ffmpeg" 2>&-||:; } && \
    { tar --strip-components=1 -C /bin -xf ffmpeg.txz "*/ffprobe" 2>&-||:; } &&\
    mkdir -p /config /media /usr/lib/emby-server/bin && \
    unzip emby.zip -d /usr/lib/emby-server/bin && \
    chown -Rh root. /bin/ff* /usr/lib/emby-server && \
    chown -Rh emby. /config /media && \
    apk del glibc-i18n && \
    rm -rf /tmp/* /var/cache/* emby.zip ffmpeg.txz glibc* $key mono.txz
    #version=$(curl -Ls https://github.com/MediaBrowser/Emby/releases.atom | \
    #            grep -A1 'link.*alternate' | grep '    <' | \
    #            sed 'N;s/\n/ /' | grep -v 'beta' | head -1 | \
    #            sed 's|.*/tag/\([^"]*\).*|\1|') && \

COPY emby.sh /usr/bin/

EXPOSE 8096 8920 7359/udp 1900/udp

HEALTHCHECK --interval=60s --timeout=15s --start-period=90s \
            CMD curl -L http://localhost:8096/

VOLUME ["/config", "/media"]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/emby.sh"]