#!/bin/bash

set -e

docker_run() {
  local name=$1
  local temp=$(${DOCKER} ps | grep $name | awk '{print $1}')
  # remove $1 from the list of args
  shift

  if [ -z "$temp" ] ; then
    temp=$(${DOCKER} ps -a --filter='status=exited'| grep $name | awk '{print $1}')
    if [ -n "$temp" ] ; then
      echo "WARN: $name was ${temp} needs to be removed" >&2
      ${DOCKER} rm "$temp" >/dev/null
    fi
    ${DOCKER} run --name=$name $@
  else
    echo "WARN: $name already running as $temp" >&2
  fi
}

mysql_start() {
    docker_run "$1" -e MYSQL_ROOT_PASSWORD=secretpw -d mysql:latest
}

usage() {
  echo "$0
  --start-mysql                    start mysql container if missing
  --link-mysql                     links mysql container
  --mysql-name  <container-name>   set mysql container name
  --name        <container-name>   set kamailio container name
  --dist        <dist>             base debian distribution to be used

Defaults:
DIST=${DIST}
IMG_BASE=${IMG_BASE}
KAM_BASE_NAME=${KAM_BASE_NAME}
"
}
# command line handling
CMDLINE_OPTS="start-mysql,link-mysql,mysql-name:,dist:,name:,help"

_opt_temp=$(getopt --name docker_kamdev.sh -o h --long $CMDLINE_OPTS -- "$@")
if [ $? -ne 0 ]; then
  echo "Try '$0 --help' for more information." >&2
  exit 1
fi
eval set -- "$_opt_temp"

# defaults
DOCKER="/usr/bin/docker"
DIST="jessie"
IMG_BASE="linuxmaniac/pkg-kamailio-docker"
MYSQL_NAME="kamailio-mysql"
KAM_BASE_NAME="kam-dev"

_opt_start_mysql=false
_opt_link_mysql=false
_opt_expose_port=true

while :; do
  case "$1" in
  --start-mysql)
    _opt_start_mysql=true; _opt_link_mysql=true
    ;;
  --link-mysql)
    _opt_link_mysql=true
    ;;
  --mysql-name)
    shift; _opt_link_mysql=true; MYSQL_NAME="$1"
    ;;
  --name)
    shift; KAM_NAME="$1"
    ;;
  --dist)
    shift; DIST="$1"
    ;;
  -h|--help)
    usage ; exit 0;
    ;;
  --)
    shift; break
    ;;
  *)
    echo "Internal getopt error! $1" >&2
    exit 1
    ;;
  esac
  shift
done

[ -z "${BASE_GIT_DIR}" ] && BASE_GIT_DIR="${HOME}/Projects"
[ -z "${KAM_DIR}" ] && KAM_DIR="${BASE_GIT_DIR}/kamailio"
[ -z "${KAM_CONF_DIR}" ] && KAM_CONF_DIR="${BASE_GIT_DIR}/kamailio_dev"

case "${DIST}" in
  jessie|wheeze|squeeze)
    img="${IMG_BASE}:${DIST}"
    ;;
  *)
    echo "ERROR: ${DIST} not yet supported" >&2
    exit 1
    ;;
esac

[ -z "${KAM_NAME}" ] && KAM_NAME="${KAM_BASE_NAME}-${DIST}"

OPTS="-i -t"
OPTS+=" -v ${KAM_DIR}:/code:rw"

if [ -d "${KAM_CONF_DIR}" ] ; then
  OPTS+=" -v ${KAM_CONF_DIR}:/kamailio_dev"
fi

if $_opt_expose_port ; then
  OPTS+=" -p 127.0.0.1:5060:5060/udp"
fi

if $_opt_link_mysql ; then
  OPTS+=" --link ${MYSQL_NAME}:mysql"
fi

if $_opt_start_mysql ; then
  mysql_start "${MYSQL_NAME}"
fi

docker_run ${KAM_NAME} ${OPTS} ${img} /bin/bash
