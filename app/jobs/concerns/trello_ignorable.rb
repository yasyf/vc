module Concerns
  module TrelloIgnorable
    extend ActiveSupport::Concern

    IGNORED_COMPANY_PREFIX = 'jobs/company_sync/ignored/trello_id'

    private

    def ignored?(trello_id)
      Rails.cache.exist?("#{IGNORED_COMPANY_PREFIX}/#{trello_id}")
    end

    def ignore!(trello_id)
      Rails.cache.write("#{IGNORED_COMPANY_PREFIX}/#{trello_id}", true, expires_in: 1.month)
    end
  end
end
