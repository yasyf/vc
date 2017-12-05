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

  def describe
    email_s = meta[:email_subject] ?  "email (#{meta[:email_subject]})" : 'email'
    name_s = subject.investor.present? ? Util.html_person(subject.investor) : subject.name
    case action.to_sym
      when :investor_opened
        "#{name_s} opened your #{arg1 ? 'intro' : email_s}."
      when :investor_replied
        "#{name_s} replied to your #{arg1 ? 'intro' : email_s}."
      when :investor_clicked
        "#{name_s} clicked your link to <a href=#{arg2} target='_blank'>#{Util.parse_domain(arg2)}</a>."
      when :intro_requested
        "You requested an intro to #{name_s}."
      else
        nil
    end
  end
end
