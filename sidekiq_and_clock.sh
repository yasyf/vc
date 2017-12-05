#!/bin/bash

bundle exec sidekiq -C config/sidekiq.yml &
if [ -n "$RUN_CLOCK" ]; then
  bundle exec zhong config/zhong.rb &
fi
wait
