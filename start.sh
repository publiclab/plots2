#!/bin/bash -l

pidfile=/app/tmp/pids/server.pid

bundle check || bundle install
yarn

if [ -f $pidfile ] ; then
  >&2 echo 'Server PID file already exists. Removing it...';
  rm $pidfile;
fi

bundle exec passenger-config compile-nginx-engine
bundle exec passenger start --max-pool-size 16 --min-instances 16 -p 4000
