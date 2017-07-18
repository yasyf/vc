class Founder < ApplicationRecord
  has_and_belongs_to_many :companies, -> { distinct }
  has_many :target_investors

  validates :first_name, presence: true
  validates :last_name, presence: true

  devise

  def self.find_or_create_from_social!(first_name, last_name, social, context: nil)
    name_hash = {first_name: first_name, last_name: last_name}
    social = social.compact
    attrs = social.merge(name_hash)

    if social.blank?
      return (context.present? && context.founders.where(name_hash).empty?) ? create!(name_hash) : nil
    end

    found = social.inject(none) { |scope, (attr, val)| scope.or(where(attr => val)) }.first
    found.present? ? found.tap { |f| f.update!(attrs) } : create!(attrs)
  end

  def self.from_omniauth(auth)
    from_email(auth.info.email, auth.info.first_name, auth.info.last_name) if auth.present?
  end

  def self.from_email(email, first_name = nil, last_name = nil)
    where(email: email).first_or_create! do |f|
      f.first_name = first_name
      f.last_name = last_name
    end
  end

  def name
    "#{first_name} #{last_name}"
  end

  def domain
    return nil unless email.present?
    email.split('@').last
  end

  def drf?
    companies.any?(&:funded?) || domain == ENV['DOMAIN']
  end

  def as_json(options = {})
    super options.reverse_merge(only: [:id, :first_name, :last_name], methods: [:drf?])
  end
end
