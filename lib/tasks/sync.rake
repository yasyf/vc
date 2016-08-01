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
end
