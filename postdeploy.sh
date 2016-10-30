#!/bin/bash

bundle exec rake db:migrate
bundle exec rake sync:teams
bundle exec rake sync:competitors
