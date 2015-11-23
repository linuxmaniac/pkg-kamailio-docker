FROM debian:wheezy

ENV REFRESHED_AT 2015-11-24

RUN rm -rf /var/lib/apt/lists/* && apt-get update
RUN apt-get install --assume-yes   pbuilder mysql-client gdb screen sip-tester sipsak psmisc joe lynx less clang-3.4

VOLUME /code

RUN mkdir -p /usr/local/src/pkg
COPY debian /usr/local/src/pkg/debian

# get build dependences
RUN cd /usr/local/src/pkg/ && /usr/lib/pbuilder/pbuilder-satisfydepends-experimental

# clean
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 5060

