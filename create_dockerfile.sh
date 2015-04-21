create_dockerfile() {
  mkdir -p "${dist}"
  cp -r "src/pkg/kamailio/deb/${dist}/" "${dist}/debian/"
  cat > "${dist}/Dockerfile" <<EOF
FROM debian:${dist}

RUN rm -rf /var/lib/apt/lists/* && apt-get update
RUN apt-get install --assume-yes \
  pbuilder mysql-client gdb screen sip-tester psmisc joe

VOLUME /code

RUN mkdir -p /usr/local/src/pkg
COPY debian /usr/local/src/pkg/debian

# get build dependences
RUN cd /usr/local/src/pkg/ && /usr/lib/pbuilder/pbuilder-satisfydepends-experimental

# clean
RUN rm -rf /var/lib/apt/lists/*

EXPOSE 5060

# docker build --tag="kamailio-dev-${dist}" .
# mysql container
# docker run --name kamailio-mysql
#  -e MYSQL_ROOT_PASSWORD=secretpw -d mysql:latest
# linked with mysql container
# docker run -i -t -p 127.0.0.1:5060:5060/udp
#   -v $(pwd)/../kamailio_dev:/kamailio_dev -v $(pwd):/code:rw
#   --link kamailio-mysql:mysql kamailio-dev-${dist}:latest bash
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
