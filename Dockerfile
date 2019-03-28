# Dockerfile # Plots2
# https://github.com/publiclab/plots2

FROM ruby:2.4.4-stretch

LABEL description="This image deploys Plots2."

# Set correct environment variables.
RUN mkdir -p /app
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

RUN echo "umask 0002" >> /etc/bash.bashrc

# Install bundle of gems
WORKDIR /tmp
COPY Gemfile /tmp/Gemfile
COPY Gemfile.lock /tmp/Gemfile.lock
ADD . /app
RUN mkdir -p /app/public /app/log && touch /app/passenger.4000.pid /app/passenger.4000.pid.lock && chmod a+w /tmp /app/public /app/Gemfile.lock /app/passenger.4000.pid /app/passenger.4000.pid.lock /app/log /app/spec -R
RUN passenger-config compile-nginx-engine --connect-timeout 60 --idle-timeout 60

# Add unprivileged user
RUN adduser --disabled-password --gecos '' plots
USER plots

RUN bundle install --jobs 4
WORKDIR /app


RUN bower install
RUN yarn install && yarn upgrade