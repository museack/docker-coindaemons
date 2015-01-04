# version 1.4-1
# docker-version 0.9.1
FROM        phusion/baseimage:0.9.13
MAINTAINER  museack "muse.ack.jn@gmail.com"

EXPOSE      8368
CMD         ["/sbin/my_init"]

RUN	apt-get update \
	&& apt-get install -y libtool \
	&& apt-get install -y wget \
        && apt-get install -y bsdmainutils \
        && apt-get install -y autoconf \
        && apt-get install -y makepasswd \
        && apt-get install -y libqrencode-dev \
        && apt-get install -y libcurl4-openssl-dev \
        && apt-get install -y libdb5.1++-dev \
        && apt-get install -y ntp \
        && apt-get install -y git \
        && apt-get install -y build-essential \
        && apt-get install -y libssl-dev \
        && apt-get install -y libdb5.1-dev \
        && apt-get install -y libboost-all-dev \
        && apt-get install -y libminiupnpc-dev \
        && apt-get install -y make \
        && apt-get install -y automake \
	&& pwd \
	&& apt-get autoclean 

#	&& git clone https://github.com/syscoin/syscoin

COPY	. /

#RUN	cd syscoin/src \
#	&& make -f makefile.unix \
#	&& cp tacocoind /usr/local/bin \
#	&& adduser --disabled-password --gecos "mazamulti" --uid 2211 --gid 2211 mazamulti \
#	&& groupadd --gid 2211 mazamulti \
#	&& touch /etc/service/sshd/down \
#	&& cd ../.. \
#	mkdir /etc/service/syscoind \
#	&& mv run /etc/service/syscoind \
#	&& chmod 700 /etc/service/syscoind/run
