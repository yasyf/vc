namespace :sync do
  desc "Sync companies and lists from Trello"
  task trello: :environment do
    List.sync!
    Company.sync!
  end
end
