FROM nginx:latest
MAINTAINER Goran Mekić <meka@lugons.org>

ADD . /app
RUN /app/build.sh
