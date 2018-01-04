#!/bin/bash

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

bundle exec sidekiq -C config/sidekiq.yml -t 25 &
if [ -n "$RUN_CLOCK" ]; then
  bundle exec zhong config/zhong.rb &
fi

wait