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
ADD nodesource.gpg.key /tmp/nodesource.gpg.key
RUN apt-key add /tmp/nodesource.gpg.key && apt-get update -qq \
    && apt-get install --no-install-recommends -y build-essential libmariadbclient-dev \
                wget curl procps cron make nodejs unzip \
                apt-transport-https libfreeimage3 \
    && npm install -g yarn


RUN apt-get install -y fonts-liberation libappindicator3-1 libasound2 libatk-bridge2.0-0 \
                       libatspi2.0-0 libgtk-3-0 libnspr4 libnss3 libx11-xcb1 libxss1 \
                       libxtst6 xdg-utils phantomjs lsb-release
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg -i google-chrome-stable_current_amd64.deb && \
    apt-get -fy install && \
    wget https://chromedriver.storage.googleapis.com/74.0.3729.6/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip && \
    mv chromedriver /usr/local/bin/chromedriver && \
    chmod +x /usr/local/bin/chromedriver

WORKDIR /tmp
ADD Gemfile /tmp/Gemfile
ADD Gemfile.lock /tmp/Gemfile.lock
RUN bundle install --jobs=4

WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
COPY start.sh /app/start.sh

CMD [ "bash", "-l", "start.sh" ]
