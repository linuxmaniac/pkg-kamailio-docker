#!/bin/bash

create_dockerfile() {
  rm -rf "${dist}"
  mkdir -p "${dist}"
  cp -r "src/pkg/kamailio/deb/${dist}/" "${dist}/debian/"
  cat >"${dist}"/Dockerfile <<EOF
FROM ${base}:${dist}

# Important! Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images and things like 'apt-get update' won't be using
# old cached versions when the Dockerfile is built.
ENV REFRESHED_AT ${DATE}

EOF

if [ -n "${archived}" ] ; then
cat >>"${dist}"/Dockerfile <<EOF
RUN echo "deb http://archive.debian.org/debian ${dist} main" > /etc/apt/sources.list; \
    echo "deb http://archive.debian.org/debian ${dist}-lts main" >> /etc/apt/sources.list ; \
    echo "Acquire::Check-Valid-Until false;" >> /etc/apt/apt.conf

EOF
elif [ "${base}" = "debian" ] ; then
cat >>"${dist}"/Dockerfile <<EOF
# avoid httpredir errors
RUN sed -i 's/httpredir/ftp.us/g' /etc/apt/sources.list

EOF
fi

cat >>"${dist}"/Dockerfile <<EOF
RUN rm -rf /var/lib/apt/lists/* && apt-get update
RUN apt-get install --assume-yes ${CLANG} pbuilder ${TOOLS}

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

TOOLS="mysql-client gdb screen sip-tester psmisc joe vim lynx less"

case ${dist} in
	squeeze|wheezy) CLANG="" TOOLS="$TOOLS sipsak" ;;
	jessie)	        CLANG=" clang-3.5" TOOLS="$TOOLS sipsak"  ;;
	stretch)        CLANG=" clang-3.7" ;;
	sid)            CLANG=" clang-3.8" ;;
esac

case ${dist} in
  xenial|trusty|precise) base=ubuntu ;;
  squeeze|wheezy|jessie|stretch|sid) base=debian ;;
  *)
    echo "ERROR: no ${dist} base found"
    exit 1
    ;;
esac

case ${dist} in
  squeeze) archived=true ;;
esac

create_dockerfile
