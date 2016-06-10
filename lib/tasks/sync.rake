namespace :sync do
  desc "Sync companies from Trello"
  task trello: :environment do
    Company.sync!
  end
end
