[![logo](https://raw.githubusercontent.com/dperson/emby/master/logo.png)](http://emby.media/)

# Emby

Emby docker container

# What is Emby?

Emby Server automatically streams (and converts, if needed) your media
on-the-fly to play on any device.

# How to use this image

When started the emby web inteface will listen on port 8096 in the container.

## Hosting a Emby instance

    sudo docker run --name emby -e TZ=EST5EDT -p 8096:8096 -p 8920:8920 \
                -p 7359:7359/udp -p 1900:1900/udp -d dperson/emby

OR use local storage:

    sudo docker run --name emby -e TZ=EST5EDT -p 8096:8096 -p 8920:8920 \
                -p 7359:7359/udp -p 1900:1900/udp \
                -v /path/to/directory:/config \
                -v /path/to/media:/media -d dperson/emby

## Configuration

    sudo docker run -it --rm dperson/emby -h

    Usage: emby.sh [-opt] [command]
    Options (fields in '[]' are optional, '<>' are required):
        -h          This help
        -t ""       Configure timezone
                    possible arg: "[timezone]" - zoneinfo timezone for container

    The 'command' (if provided and valid) will be run instead of emby

ENVIRONMENT VARIABLES (only available with `docker run`)

 * `TZ` - As above, configure the zoneinfo timezone, IE `EST5EDT`
 * `USERID` - Set the UID for the app user
 * `GROUPID` - Set the GID for the app user

## Examples

Any of the commands can be run at creation with `docker run` or later with
`docker exec emby.sh` (as of version 1.3 of docker).

### Setting the Timezone

    sudo docker run --name emby -p 8096:8096 -p 8920:8920 -p 7359:7359/udp \
                -p 1900:1900/udp -d dperson/emby -t EST5EDT

OR using `environment variables`

    sudo docker run --name emby -e TZ=EST5EDT -p 8096:8096 -p 8920:8920 \
                -p 7359:7359/udp -p 1900:1900/udp -d dperson/emby

Will get you the same settings as

    sudo docker run --name emby -p 8096:8096 -p 8920:8920 -p 7359:7359/udp \
                -p 1900:1900/udp -d dperson/emby
    sudo docker exec emby emby.sh -t EST5EDT ls -AlF /etc/localtime
    sudo docker restart emby

# User Feedback

## Issues

If you have any problems with or questions about this image, please contact me
through a [GitHub issue](https://github.com/dperson/emby/issues).
