# Dockerfile # Plots2
# https://github.com/publiclab/plots2

FROM ruby:2.4.4-stretch

LABEL description="This image deploys Plots2."

# Set correct environment variables.
RUN mkdir -p /app
ENV HOME /root
ENV PHANTOMJS_VERSION 2.1.1

RUN echo \
   'deb http://ftp.ca.debian.org/debian/ stretch main\n \
    deb http://ftp.ca.debian.org/debian/ stretch-updates main\n \
    deb http://security.debian.org stretch/updates main\n' \
    > /etc/apt/sources.list

# Install dependencies
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get update -qq && apt-get install -y build-essential bundler libmariadbclient-dev ruby-rmagick libfreeimage3 wget curl procps cron make nodejs
RUN wget https://github.com/Medium/phantomjs/releases/download/v$PHANTOMJS_VERSION/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 -O /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2; tar -xvf /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 -C /opt ; cp /opt/phantomjs-$PHANTOMJS_VERSION-linux-x86_64/bin/* /usr/local/bin/

# Install yarn
RUN npm config set strict-ssl false
RUN npm install -g yarn

RUN rm -r /usr/local/bundle

# Install bundle of gems
WORKDIR /tmp
ADD Gemfile /tmp/Gemfile
ADD Gemfile.lock /tmp/Gemfile.lock
RUN bundle install --jobs=4

ADD . /app
WORKDIR /app

RUN yarn install && yarn postinstall && yarn upgrade
RUN passenger-config compile-nginx-engine --connect-timeout 60 --idle-timeout 60
