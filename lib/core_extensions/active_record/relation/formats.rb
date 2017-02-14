module CoreExtensions
  module ActiveRecord
    module Relation
      module Formats
        def to_csv(options = {})
          CSV.generate do |csv|
            csv << self.first.as_json(options).keys
            self.each do |record|
              csv << record.as_json(options).values
            end
          end
        end
      end
    end
  end
end
