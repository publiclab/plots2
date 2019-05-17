# Dockerfile # Plots2
# https://github.com/publiclab/plots2

FROM ruby:2.4.4-stretch

LABEL description="This image deploys Plots2."

# Set correct environment variables.
ENV HOME /root

RUN echo \
   'deb http://ftp.ca.debian.org/debian/ stretch main\n \
    deb http://ftp.ca.debian.org/debian/ stretch-updates main\n \
    deb http://security.debian.org stretch/updates main\n \
    deb http://deb.nodesource.com/node_8.x stretch main\n' \
    > /etc/apt/sources.list

# Install dependencies
WORKDIR /tmp
ADD nodesource.gpg.key /tmp/nodesource.gpg.key
RUN apt-key add nodesource.gpg.key && apt-get update -qq \
    && apt-get install --no-install-recommends -y build-essential libmariadbclient-dev \
                wget curl procps cron make nodejs \
                apt-transport-https libfreeimage3
RUN npm config set strict-ssl false && npm install -g yarn \
    && yarn install && yarn upgrade

# Install bundle of gems
ADD Gemfile /tmp/Gemfile
ADD Gemfile.lock /tmp/Gemfile.lock
RUN bundle install --jobs=4

ADD . /app
WORKDIR /app

# RUN passenger-config compile-nginx-engine --connect-timeout 60 --idle-timeout 60
