require 'csv'
require 'open-uri'

module Importers::Folders
  class Nyc < BaseFolder
    FILENAME_REGEX = /(?:\d{1,2}\/\d{1,2} )?(.+)/

    private

    def team
      Team.nyc
    end
  end
end
