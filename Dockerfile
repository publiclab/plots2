# Dockerfile # Plots2
# https://github.com/publiclab/plots2

FROM ruby:2.1.2
MAINTAINER Sebastian Silva "sebastian@fuentelibre.org"

LABEL "This image deploys Plots2."

# Set correct environment variables.
RUN mkdir -p /app
ENV HOME /root
ENV PHANTOMJS_VERSION 2.1.1 

RUN echo \
   'deb ftp://ftp.us.debian.org/debian/ jessie main\n \
    deb ftp://ftp.us.debian.org/debian/ jessie-updates main\n \
    deb http://security.debian.org jessie/updates main\n' \
    > /etc/apt/sources.list

# Install dependencies
RUN apt-get update -qq && apt-get install -y bundler libmysqlclient-dev ruby-rmagick libfreeimage3 nodejs-legacy npm wget openjdk-7-jre openjdk-7-jdk
RUN wget https://github.com/Medium/phantomjs/releases/download/v$PHANTOMJS_VERSION/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 -O /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2; tar -xvf /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 -C /opt ; cp /opt/phantomjs-$PHANTOMJS_VERSION-linux-x86_64/bin/* /usr/local/bin/
RUN npm install -g bower

# Install bundle of gems
WORKDIR /tmp
ADD Gemfile /tmp/Gemfile
ADD Gemfile.lock /tmp/Gemfile.lock
RUN bundle install --jobs 4

ADD . /app
WORKDIR /app

RUN bower install --allow-root
