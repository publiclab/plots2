# Dockerfile # Plots2
# https://github.com/publiclab/plots2

FROM ruby:2.1.2
MAINTAINER Sebastian Silva "sebastian@fuentelibre.org"

LABEL "This image deploys Plots2."

# Set correct environment variables.
RUN mkdir -p /app
ENV HOME /root

# Install dependencies
RUN apt-get update -qq && apt-get install -y bundler libmysqlclient-dev ruby-rmagick libfreeimage3 nodejs-legacy npm
RUN apt-get install openjdk-7-jre openjdk-7-jdk
RUN npm install -g bower

# Install bundle of gems
WORKDIR /tmp
ADD Gemfile /tmp/Gemfile
RUN bundle install --jobs 4

ADD . /app
WORKDIR /app

# Add the Rails app
RUN bower install --allow-root
