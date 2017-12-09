release: ./release.sh
web: bundle exec puma -C config/puma.rb
sidekiq: ./sidekiq_and_clock.sh
sidekiq_long: bundle exec sidekiq -C config/sidekiq_long.yml
