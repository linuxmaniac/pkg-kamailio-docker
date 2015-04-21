FROM debian:jessie

RUN rm -rf /var/lib/apt/lists/* && apt-get update
RUN apt-get install --assume-yes   pbuilder mysql-client gdb screen sip-tester psmisc joe

VOLUME /code

RUN mkdir -p /usr/local/src/pkg
COPY debian /usr/local/src/pkg/debian

# get build dependences
RUN cd /usr/local/src/pkg/ && /usr/lib/pbuilder/pbuilder-satisfydepends-experimental

# clean
RUN rm -rf /var/lib/apt/lists/*

EXPOSE 5060

# docker build --tag="kamailio-dev-jessie" .
# mysql container
# docker run --name kamailio-mysql
#  -e MYSQL_ROOT_PASSWORD=secretpw -d mysql:latest
# linked with mysql container
# docker run -i -t -p 127.0.0.1:5060:5060/udp
#   -v /home/vseva/Projects/pkg-kamailio-docker/../kamailio_dev:/kamailio_dev -v /home/vseva/Projects/pkg-kamailio-docker:/code:rw
#   --link kamailio-mysql:mysql kamailio-dev-jessie:latest bash
