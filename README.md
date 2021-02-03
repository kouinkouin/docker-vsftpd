# fauria/vsftpd

![docker_logo](https://raw.githubusercontent.com/fauria/docker-vsftpd/master/docker_139x115.png)![docker_fauria_logo](https://raw.githubusercontent.com/fauria/docker-vsftpd/master/docker_fauria_161x115.png)

[![Docker Pulls](https://img.shields.io/docker/pulls/fauria/vsftpd.svg?style=plastic)](https://hub.docker.com/r/fauria/vsftpd/)
[![Docker Build Status](https://img.shields.io/docker/build/fauria/vsftpd.svg?style=plastic)](https://hub.docker.com/r/fauria/vsftpd/builds/)
[![](https://images.microbadger.com/badges/image/fauria/vsftpd.svg)](https://microbadger.com/images/fauria/vsftpd "fauria/vsftpd")

This Docker container implements a vsftpd server, with the following features:

 * Centos 7 base image.
 * vsftpd 3.0
 * Virtual users
 * Passive mode
 * Logging to a file or STDOUT.

### Installation from [Docker registry hub](https://registry.hub.docker.com/r/fauria/vsftpd/).

You can download the image with the following command:

```bash
docker pull fauria/vsftpd
```

Environment variables
----

This image uses environment variables to allow the configuration of some parameters at run time:

* Variable name: `USERS`
* Default value: none
* Accepted values: Any string. Avoid whitespaces and special chars.
* Description: List of usernames for the default FTP account.

----

* Variable name: `PASS_<username>`
* Default value: Random string.
* Accepted values: Any string.
* Description: Specify a password for each user in USERS

----

* Variable name: `PASV_ADDRESS`
* Default value: Docker host IP / Hostname.
* Accepted values: Any IPv4 address or Hostname (see PASV_ADDRESS_RESOLVE).
* Description: If you don't specify an IP address to be used in passive mode, the routed IP address of the Docker host will be used. Bear in mind that this could be a local address.

----

* Variable name: `PASV_ADDR_RESOLVE`
* Default value: NO
* Accepted values: <NO|YES>
* Description: Set to YES if you want to use a hostname (as opposed to IP address) in the PASV_ADDRESS option.

----

* Variable name: `PASV_ENABLE`
* Default value: YES
* Accepted values: <NO|YES>
* Description: Set to NO if you want to disallow the PASV method of obtaining a data connection.

----

* Variable name: `PASV_MIN_PORT`
* Default value: 21100
* Accepted values: Any valid port number.
* Description: This will be used as the lower bound of the passive mode port range. Remember to publish your ports with `docker -p` parameter.

----

* Variable name: `PASV_MAX_PORT`
* Default value: 21110
* Accepted values: Any valid port number.
* Description: This will be used as the upper bound of the passive mode port range. It will take longer to start a container with a high number of published ports.

----

* Variable name: `XFERLOG_STD_FORMAT`
* Default value: NO
* Accepted values: <NO|YES>
* Description: Set to YES if you want the transfer log file to be written in standard xferlog format.

----

* Variable name: `FILE_OPEN_MODE`
* Default value: 0666
* Accepted values: File system permissions.
* Description: The permissions with which uploaded files are created. Umasks are applied on top of this value. You may wish to change to 0777 if you want uploaded files to be executable.

----

* Variable name: `LOCAL_UMASK`
* Default value: 077
* Accepted values: File system permissions.
* Description: The value that the umask for file creation is set to for local users. NOTE! If you want to specify octal values, remember the "0" prefix otherwise the value will be treated as a base 10 integer!

----

* Variable name: `REVERSE_LOOKUP_ENABLE`
* Default value: YES
* Accepted values: <NO|YES>
* Description: Set to NO if you want to avoid performance issues where a name server doesn't respond to a reverse lookup.

----

* Variable name: `PASV_PROMISCUOUS`
* Default value: NO
* Accepted values: <NO|YES>
* Description: Set to YES if you want to disable the PASV security check that ensures the data connection originates from the same IP address as the control connection. Only enable if you know what you are doing! The only legitimate use for this is in some form of secure tunnelling scheme, or perhaps to facilitate FXP support.

----
* Variable name: `PORT_PROMISCUOUS`
* Default value: NO
* Accepted values: <NO|YES>
* Description: Set to YES if you want to disable the PORT security check that ensures that outgoing data connections can only connect to the client. Only enable if you know what you are doing! Legitimate use for this is to facilitate FXP support.

----

Exposed ports and volumes
----

The image exposes ports `20` and `21`. Also, exports two volumes: `/home/vsftpd`, which contains users home directories, and `/var/log/vsftpd`, used to store logs.

When sharing a homes directory between the host and the container (`/home/vsftpd`) the owner user id and group id should be 14 and 50 respectively. This corresponds to ftp user and ftp group on the container, but may match something else on the host.

Use cases
----

1) Create a temporary container for testing purposes:

```bash
  docker run --rm -e USERS=admin -e PASS_admin=admin fauria/vsftpd
```

2) Create a container in active mode using the default user account, with a binded data directory:

```bash
docker run -d -p 21:21 -e USERS=admin -e PASS_admin=admin -v /my/data/directory:/home/vsftpd --name vsftpd fauria/vsftpd
# see logs for credentials:
docker logs vsftpd
```

3) Create a **production container** with a custom user account, binding a data directory and enabling both active and passive mode:

```bash
docker run -d -v /my/data/directory:/home/vsftpd \
-p 20:20 -p 21:21 -p 21100-21110:21100-21110 \
-e USERS="myuser1 myuser2" -e PASS_myuser1=mypass1 -e PASS_myuser2=mypass2 \
-e PASV_ADDRESS=127.0.0.1 -e PASV_MIN_PORT=21100 -e PASV_MAX_PORT=21110 \
--name vsftpd --restart=always fauria/vsftpd
```



https://security.appspot.com/vsftpd/vsftpd_conf.html
