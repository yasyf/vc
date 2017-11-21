class IntroRequestPreviewJob < ApplicationJob
  queue_as :now

  def perform(intro_request_id)
    intro_request = IntroRequest.find(intro_request_id)
    html = IntroMailer.request_preview_email(intro_request).body.encoded
    intro_request.update! preview_html: html
  end
end
