class DuplicateCompetitorJob < ApplicationJob
  queue_as :default

  def perform(competitor_id)
    ActiveRecord::Base.transaction do
      competitor = Competitor.find(competitor_id)
      other = Competitor
        .where(crunchbase_id: competitor.crunchbase_id)
        .or(Competitor.where(al_id: competitor.al_id))
        .where.not(id: competitor.id)
        .first
      return unless other.present?

      competitor.lock!
      other.lock!

      other.crunchbase_id ||= competitor.crunchbase_id
      other.al_id ||= competitor.al_id

      competitor.investments.lock
      competitor.investments.find_each do |cc|
        cc2 = Investment.where(company: cc.company, competitor: other).first_or_create!
        cc2.funded_at ||= cc.funded_at
        cc2.save!
        cc.destroy!
      end

      competitor.investors.lock
      competitor.investors.update_all competitor_id: other.id

      competitor.notes.lock
      competitor.notes.find_each do |note|
        note.update! subject: other
      end

      other.save!
      competitor.destroy!
    end
  end
end
