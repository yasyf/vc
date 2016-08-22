namespace :sync do
  desc "Sync companies and lists from Trello"
  task trello: :environment do
    List.sync!
    Company.sync!
  end

  desc "Sync votes from remote CSV"
  task :csv, [:url] => [:environment] do |t, args|
    Importers::Csv.new(args[:url]).sync!
  end

  desc "Sync teams with config"
  task teams: :environment do
    Rails.configuration.teams.each do |name, config|
      Team.where(name: name).first_or_create! unless config['ignore']
    end
  end
end
