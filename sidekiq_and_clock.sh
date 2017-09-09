#!/bin/bash

bundle exec sidekiq -C config/sidekiq.yml &
bundle exec clockwork config/clock.rb &
wait
