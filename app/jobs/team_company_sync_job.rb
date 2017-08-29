class TeamCompanySyncJob < ApplicationJob
  include Concerns::CacheIgnorable

  queue_as :default

  def perform(team, deep: false, quiet: true)
    Importers::Internal::Trello.new(team).sync!(deep: deep) do |card_data|
      next if ignored? card_data[:trello_id]

      if card_data.delete(:closed)
        Card.where(trello_id: card_data[:trello_id]).update_all(archived: true)
        next
      end

      CardSyncJob.perform_later(team, card_data.as_json, deep: deep, quiet: quiet)
    end
  end
end