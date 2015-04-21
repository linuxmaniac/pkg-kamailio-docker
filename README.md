# description

Docker Debian based Images with dependences installed ready to be used
to build Kamailio from sources

# get Kamailio source
```
git clone https://github.com/kamailio/kamailio.git
```
# usage

Example with squeeze

## pull docker images

We are going to use another container for mysql server

```
docker pull mysql:latest
```

Our image for squeeze

```
docker pull linuxmaniac/pkg-kamailio-docker:squeeze
```

## run containers
First run mysql container

```
docker run --name kamailio-mysql -e MYSQL_ROOT_PASSWORD=secretpw -d mysql:latest
```

Now we can link mysql container to ours.
The kamailio-mysql server is now available as mysql
This asumes that Kamailio git sources are in $(pwd)

```
docker run --name kamailio-dev-squeeze -i -t -p 127.0.0.1:5060:5060/udp \
 -v $(pwd):/code:rw \
 --link kamailio-mysql:mysql linxmaniac/pkg-kamailio-docker:squeeze bash
```


I usually keep my tests config on another directory so I can use it like:

```
docker run --name kamailio-dev-squeeze -i -t -p 127.0.0.1:5060:5060/udp \
 -v $(pwd):/code:rw -v $(pwd)/../kamailio_dev:/kamailio_dev \
 --link kamailio-mysql:mysql linxmaniac/pkg-kamailio-docker:squeeze bash
```
