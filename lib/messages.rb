class Messages
  PASS_PHRASES = [
    'keep in touch',
    'not interested',
    'not right now',
    'not a good fit',
    'keep in touch',
    'i can be helpful',
  ]

  def self.stage(text, sentiment)
    if sentiment&.negative? && PASS_PHRASES.any? { |p| p.in?(text.downcase) }
      TargetInvestor::RAW_STAGES.keys.index(:pass)
    else
      TargetInvestor::RAW_STAGES.keys.index(:respond)
    end
  end

  def self.intro_request(source)
    return nil unless source.present?
    match = /#{IntroRequest::TOKEN_MAGIC}([\w]{10})/.match(source)
    IntroRequest.where(token: match[1]).first if match.present?
  end
end