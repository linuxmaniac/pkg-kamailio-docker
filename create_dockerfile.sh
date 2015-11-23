create_dockerfile() {
  mkdir -p "${dist}"
  cp -r "src/pkg/kamailio/deb/${dist}/" "${dist}/debian/"
  cat > "${dist}/Dockerfile" <<EOF
FROM debian:${dist}

# Important! Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images and things like `apt-get update` won't be using
# old cached versions when the Dockerfile is built.
ENV REFRESHED_AT ${DATE}

RUN rm -rf /var/lib/apt/lists/* && apt-get update
RUN apt-get install --assume-yes \
  pbuilder mysql-client gdb screen sip-tester sipsak psmisc joe lynx less clang-3.4

VOLUME /code

RUN mkdir -p /usr/local/src/pkg
COPY debian /usr/local/src/pkg/debian

# get build dependences
RUN cd /usr/local/src/pkg/ && /usr/lib/pbuilder/pbuilder-satisfydepends-experimental

# clean
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 5060

EOF

}

dist=${1:-sid}

DATE=$(date --rfc-3339=date)

if [ -d src ] ; then
	(cd src && git pull)
else
	git clone https://github.com/kamailio/kamailio.git src
fi

if ! [ -d "src/pkg/kamailio/deb/${dist}/" ] ; then
	echo "ERROR: no ${dist} support"
	exit 1
fi

create_dockerfile
