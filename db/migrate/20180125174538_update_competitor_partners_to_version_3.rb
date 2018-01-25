class UpdateCompetitorPartnersToVersion3 < ActiveRecord::Migration[5.1]
  def change
    update_view :competitor_partners,
      version: 3,
      revert_to_version: 2,
      materialized: true
  end
end
