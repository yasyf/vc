require 'csv'
require 'open-uri'

module Importers::Folders
  class Nyc < BaseFolder
    FILENAME_REGEX = /(?:\d{1,2}\/\d{1,2} )?(.+)/
  end

  def team
    Team.nyc
  end
end
