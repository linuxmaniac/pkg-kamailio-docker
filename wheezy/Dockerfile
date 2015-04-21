FROM debian:wheezy

RUN rm -rf /var/lib/apt/lists/* && apt-get update
RUN apt-get install --assume-yes   pbuilder mysql-client gdb screen sip-tester psmisc joe

VOLUME /code

RUN mkdir -p /usr/local/src/pkg
COPY src/pkg /usr/local/src/pkg

# get build dependences
RUN cp -r /usr/local/src/pkg/kamailio/deb/wheezy/ /tmp/debian
RUN cd /tmp && /usr/lib/pbuilder/pbuilder-satisfydepends-experimental

# clean
RUN rm -rf /var/lib/apt/lists/*

EXPOSE 5060

# docker build --tag="kamailio-dev-wheezy" .
# mysql container
# docker run --name kamailio-mysql
#  -e MYSQL_ROOT_PASSWORD=secretpw -d mysql:latest
# linked with mysql container
# docker run -i -t -p 127.0.0.1:5060:5060/udp
#   -v /home/vseva/Projects/pkg-kamailio-docker/../kamailio_dev:/kamailio_dev -v /home/vseva/Projects/pkg-kamailio-docker:/code:rw
#   --link kamailio-mysql:mysql kamailio-dev-wheezy:latest bash
