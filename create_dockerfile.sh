create_dockerfile() {
  mkdir -p "${dist}"
  cp -r "src/pkg/kamailio/deb/${dist}/" "${dist}/debian/"
  cat > "${dist}/Dockerfile" <<EOF
FROM debian:${dist}

RUN rm -rf /var/lib/apt/lists/* && apt-get update
RUN apt-get install --assume-yes \
  pbuilder mysql-client gdb screen sip-tester sipsak psmisc joe lynx

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

if [ -d src ] ; then
	(cd src && git pull)
else
	git clone https://github.com/kamailio/kamailio.git src
fi

case "$dist" in
	sid|unstable)
		if ! [ -d src/pkg/kamailio/deb/sid ] ; then
			cp -r src/pkg/kamailio/deb/debian src/pkg/kamailio/deb/sid
		fi
		dist=sid
		;;
esac

if ! [ -d "src/pkg/kamailio/deb/${dist}/" ] ; then
	echo "ERROR: no ${dist} support"
	exit 1
fi

create_dockerfile
