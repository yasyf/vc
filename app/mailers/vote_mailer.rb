class VoteMailer < ApplicationMailer
  def funding_decision_email(to, company)
    @company = company
    @stats = company.stats
    @yes_percent = company.votes.count > 0 ? @stats[:yes_votes].to_f / company.votes.count : 0
    mail to: to, subject: "#{SUBJECT_HEADER} #{company.name} Funding Decision"
  end
end
