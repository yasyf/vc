class VoteMailer < ApplicationMailer
  def upcoming_pitch_email(to, company)
    @company = company
    mail to: to, subject: "#{SUBJECT_HEADER} [#{company.team.name.titleize}] #{company.name} Upcoming Pitch"
  end

  def funding_decision_email(to, company)
    @company = company
    @votes = company.pitch.votes
    @stats = company.pitch.stats
    @yes_percent = @votes.final.count > 0 ? @stats[:yes_votes].to_f / @votes.final.count : 0
    mail(to: to, subject: "#{SUBJECT_HEADER} [#{company.team.name.titleize}] #{company.name} Funding Decision") do |format|
      format.html { render layout: 'fancy_mailer' }
      format.text
    end
  end

  def vote_warning_email(to, company, time_remaining)
    @company = company
    @deadline = company.team.time_now + time_remaining.seconds
    @late = @deadline < company.team.time_now
    mail to: to, subject: "#{SUBJECT_HEADER} [#{company.team.name.titleize}] #{company.name} Vote Needed"
  end

  def vote_warning_team_email(to, missing_users, company, time_remaining)
    @missing_users = missing_users
    @company = company
    @deadline = company.team.time_now + time_remaining.seconds
    @late = @deadline < company.team.time_now
    mail to: to, subject: "#{SUBJECT_HEADER} [#{company.team.name.titleize}] #{company.name} Votes Needed"
  end
end
