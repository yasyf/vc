#!/bin/bash

bundle exec sidekiq -C config/sidekiq.yml &
bundle exec zhong config/zhong.rb &
wait
