namespace :scripts do
  namespace :slack do
    desc "Detonate All The Bombs"
    task :detonate_bombs, [:team] => [:environment] do |t, args|
      Slack::DetonateBombsJob.perform_later(args[:team])
    end

    desc "Collect Evergreen Advice"
    task collect_evergreens: :environment do
      Slack::CollectEvergreensJob.perform_later
    end
  end
end
