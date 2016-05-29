class VoteMailer < ApplicationMailer
  def funding_decision_email(to, company)
    @company = company
    @stats = company.stats
    @yes_percent = company.votes.count > 0 ? @stats[:yes_votes].to_f / company.votes.count : 0
    mail to: to, subject: "#{SUBJECT_HEADER} #{company.name} Funding Decision"
  end

  def vote_warning_email(to, company, time_remaining)
    @company = company
    @deadline = Time.now + time_remaining.seconds
    @late = @deadline < Time.now
    mail to: to, subject: "#{SUBJECT_HEADER} #{company.name} Vote Needed"
  end

  def vote_warning_team_email(to, missing_users, company, time_remaining)
    @missing_users = missing_users
    @company = company
    @deadline = Time.now + time_remaining.seconds
    @late = @deadline < Time.now
    mail to: to, subject: "#{SUBJECT_HEADER} #{company.name} Votes Needed"
  end
end
