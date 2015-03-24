FROM debian:jessie
MAINTAINER Goran Mekić <meka@lugons.org>

ADD . /app
RUN /app/build.sh
CMD /run.sh
VOLUME /meka.rs
