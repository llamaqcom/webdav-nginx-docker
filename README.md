# WebDAV container

Webdav implementation using nginx - based on Debian stable-slim (for smaller image size) with optional HTTP Basic Auth.

> :warning: **DEPRECATION WARNING**: This container is deprecated in favor of [llamaq/nginx-extras](https://hub.docker.com/repository/docker/llamaq/nginx-extras) that provides more flexible approach with configuration files.

## Usage

Here is a basic snippet to help you get started creating a container.

```
docker run -dit --restart unless-stopped \
    --name webdav \
    -p 127.0.0.1:8080:80 \
    -v </path/to/data>:/opt/webdav \
    -e HT_USER=webdav \
    -e HT_PASS=webdav \
    llamaq/webdav
```

Now you can reach out to your newly created container by typing into the web browser address bar `127.0.0.1:8080`.

## Parameters and Environment Variables

You can customize your container using runtime parameters and environment variables. Parameters are separated by a colon as follows `external:internal` and variables are set as follows `variable=value`.

List of supported parameters:

| Parameter | Function |
| :----: | --- |
| `-p 80` | Webserver port. |
| `-v /opt/webdav` | WebDAV directory. |
| `-v /opt/config` | *(optional)* Configuration directory. Place here your `htaccess` file if needed. |

List of supported environment variables:

| Variable | Function |
| :----: | --- |
| `-e PUID=1000` | *(optional)* for UserID - see below for explanation (default `1000`). |
| `-e PGID=1000` | *(optional)* for GroupID - see below for explanation (default `1000`). |
| `-e HT_USER` | *(optional)* for HTTP Basic Auth user - see below for explanation (default empty). |
| `-e HT_PASS` | *(optional)* for HTTP Basic Auth password - see below for explanation (default empty). |


### Network

For example, `-p 127.0.0.1:8080:80` would expose port `80` from inside the container to the host's IP `127.0.0.1` on port `8080` outside the container. It can be used in conjunction with reverse proxy such as nginx or lighttpd running on the host. Please note, by default Docker bypasses iptables/ufw rules on host, so it's **strongly** recommended limit host's port exposure to `localhost` and use this container in conjunction with reverse proxy which supports TLS with SSL certificate. You can grab one from [Let's Encrypt](https://letsencrypt.org/) for free.

### Authentication modes

As for HTTP Basic Auth, three options are available:

- **No authentication:** *(default mode)* `HT_USER` and `HT_PASS` parameters are not provided; `htpasswd` file is absent in `/opt/config` volume.
- **Single user mode:** Use `HT_USER` and `HT_PASS` parameters, i.e. `-e HT_USER=webdav` and `-e HT_PASS=webdav`. Also you can set password variable from a file by using a special prepend `FILE__`. For example, `-e FILE__HT_PASS=/path/to/secrets/mysecretpassword` will set the environment variable `HT_PASS` based on the contents of the `/path/to/secrets/mysecretpassword` file.
- **Multiple users mode:** If more users needed for HTTP Basic Auth, you can create `htpasswd` file in the config directory passed as `/opt/config` parameter. For example, create `/path/to/config_dir/htaccess` file and then use `-v </path/to/config_dir>:/opt/config` as parameter. If `htaccess` file exists, `HT_USER` and `HT_PASS` parameters are ignored.

### File permissions

When using volumes (-v flags) permissions issues can arise between the host OS and the container. You can avoid this issue by specifying the user `PUID` and group `PGID` value. For example, `-e PUID=1000 -e PGID=33`. Default values for `PUID` and `PGID` are `1000`, if no environment variables are provided.

## License

This container and its code is licensed under the MIT License and provided "AS IS", without warranty of any kind.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
