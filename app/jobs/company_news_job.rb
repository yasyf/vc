class CompanyNewsJob < ApplicationJob
  queue_as :default

  def perform
    Tweeter.where(owner_type: 'Company', owner_id: Company.portfolio).pluck(:id).each do |tweeter_id|
      TweeterNewsJob.perform_later(tweeter_id)
    end
  end
end
