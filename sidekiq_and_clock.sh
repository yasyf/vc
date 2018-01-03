#!/bin/bash

bundle exec sidekiq -C config/sidekiq.yml -t 25 &
PID1=$!

if [ -n "$RUN_CLOCK" ]; then
  bundle exec zhong config/zhong.rb &
  PID2=$!
fi

trap "kill -TERM $PID1 $PID2" SIGINT SIGTERM EXIT

wait
