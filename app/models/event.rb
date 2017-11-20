class Event < ApplicationRecord
  belongs_to :subject, polymorphic: true

  validates :subject, presence: true
  validates :action, presence: true

  def as_json(options = {})
    super options.reverse_merge(methods: [:meta])
  end

  def meta
    case action.to_sym
      when :investor_replied
        { email_subject: arg2.present? ? Email.find(arg2).subject : nil }
      else
        {}
    end
  end
end
