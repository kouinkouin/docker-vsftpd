#!/bin/bash

REPO=vsftpd
VERSION=1.1.1

if [  ! -f Dockerfile ]; then
  echo "not a docker configuration"
  return 1
fi

docker stop $REPO
docker rm $REPO
docker rmi mhus/$REPO:$VERSION

if [ "$1" = "clean" ]; then
  docker rmi mhus/$REPO:$VERSION
  docker build --no-cache -t mhus/$REPO:$VERSION .
  shift
else
	docker build -t mhus/$REPO:$VERSION .
fi

if [ "$1" = "test" ]; then
  docker run -d --name $REPO \
    -e USERS="user1 user2 user3" \
    -e PASSWD_user1=abc \
    -e PASSWD_user2=xxx \
    -e PASSWD_user3=asd \
    -e PASV_MIN_PORT=21100 \
    -e PASV_MAX_PORT=21110 \
    -e PASV_ADDRESS=127.0.0.1 \
    -p 20:20 \
    -p 21:21 \
    -p 21100-21110:21100-21110 \
    mhus/$REPO:$VERSION
  docker logs -f $REPO

fi

if [ "$1" = "push" ]; then
    docker push "mhus/$REPO:$VERSION"
    docker tag "mhus/$REPO:$VERSION" "mhus/$REPO:last"
    docker push "mhus/$REPO:last"
fi 
