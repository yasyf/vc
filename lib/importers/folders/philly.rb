require 'csv'
require 'open-uri'

module Importers::Folders
  class Philly < BaseFolder
    FILENAME_REGEX = [/(?:(.*) Voting)/, /(?:\d{1,2}\/\d{1,2} )?(.+)/]

    private

    def team
      Team.phl
    end
  end
end
