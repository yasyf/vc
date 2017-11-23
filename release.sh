#!/bin/bash

fetch_site() {
  URL="https://$MARKETING_DOMAIN"
  echo "Fetching $URL"
  until $(curl --output /dev/null --silent -L --fail $URL); do
    echo "Waiting..."
    sleep 5
  done
  echo "Done!"
}

rake db:migrate

for run in {1..3}; do
  sleep 5
  echo "Run $run"
  fetch_site
done