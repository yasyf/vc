class DuplicateCompanyJob < ApplicationJob
  queue_as :default

  def perform(company_id, attrs)
    ActiveRecord::Base.transaction do
      company = Company.find(company_id)
      return if company.pitches.present? || company.cards.present? || company.team.present?

      other = Company.where(attrs).where.not(id: company.id).first
      return unless other.present?

      company.lock!
      other.lock!

      company.investments.lock
      company.investments.find_each do |cc|
        cc2 = Investment.where(company: other, competitor: cc.competitor).first_or_create!
        cc2.funded_at ||= cc.funded_at
        cc2.save!
        cc.destroy!
      end

      company.founders.lock
      company.founders.find_each do |founder|
        founder.companies.delete(company)
        founder.companies << other
        founder.save!
      end

      other.save!
      company.destroy!
    end
  end
end
