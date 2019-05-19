#!/bin/bash -l

pidfile=/app/tmp/pids/server.pid

bundle check || bundle install
bower install --allow-root

if [ -f $pidfile ] ; then
  >&2 echo 'Server PID file already exists. Removing it...';
  rm $pidfile;
fi

bundle exec passenger start
