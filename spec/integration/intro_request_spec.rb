require 'rails_helper'
require 'google/cloud/language'

RSpec.describe 'intro request', type: :request do
  before do
    allow(GoogleCloud::Language).to receive_message_chain(:client, :document, :sentiment) { OpenStruct.new(score: -1, magnitude: 1) }
    allow_any_instance_of(IntroMailer).to receive(:set_mailgun_options!)

    @founder = FactoryBot.create(:founder, :with_companies)
    @company = @founder.primary_company
    @investor = FactoryBot.create(:investor)
    @target_investor = FactoryBot.create(:target_investor, founder: @founder, investor: @investor)

    @investor2 = FactoryBot.create(:investor)

    sign_in @founder
  end

  it 'asks for an opt in' do
    expect do
      perform_enqueued_jobs do
        post external_api_v1_intros_path, params: {
          intro_request: {
            target_investor_id: @target_investor.id,
          }
        }
        expect(response).to be_success
      end
    end.to change { IntroRequest.count }.from(0).to(1)
    expect(ActionMailer::Base.deliveries.count).to eq(1)

    mail = ActionMailer::Base.deliveries.last
    expect(mail.to.length).to eq(1)
    expect(mail.to.first).to eq(@investor.email)
    expect(mail.subject).to include(@company.name)
    expect(mail.body.encoded).to include(@founder.first_name)
    expect(mail.body.encoded).to include(@investor.first_name)
    expect(mail.body.encoded).to include(@company.description)
    expect(mail.body.encoded).to include(external_vcwiz_opt_in_path)
    expect(mail.body.encoded).to include(IntroRequest.last.token)
  end

  it 'makes the intro' do
    intro_request = FactoryBot.create(:intro_request, founder: @founder, company: @company, investor: @investor)

    perform_enqueued_jobs do
      get external_vcwiz_opt_in_path, params: {
        optin: true,
        accept: true,
        token: intro_request.token,
      }
    end
    expect(response).to be_success
    expect(ActionMailer::Base.deliveries.count).to eq(1)

    mail = ActionMailer::Base.deliveries.last
    expect(mail.to.length).to eq(2)
    expect(mail.to).to include(@founder.email)
    expect(mail.to).to include(@investor.email)
    expect(mail.subject).to include(@company.name)
    expect(mail.body.encoded).to include(@founder.first_name)
    expect(mail.body.encoded).to include(@investor.first_name)
    expect(mail.body.encoded).to include(@company.description)
  end

  it 'tracks outreach' do
    expect do
      post external_api_v1_message_path, params: {
        To: @investor2.email,
        From: @founder.email,
        'stripped-text': 'hi'
      }
      expect(response).to be_success
    end.to change { TargetInvestor.count }.by(1)

    target = TargetInvestor.last
    expect(target.investor).to eq(@investor2)
    expect(target.email).to eq(@investor2.email)
    expect(target.stage).to include('waiting')
  end

  it 'tracks responses and recognizes passes' do
    expect do
      post external_api_v1_message_path, params: {
        From: @investor2.email,
        To: @founder.email,
        'stripped-text': 'hello'
      }
      expect(response).to be_success
    end.to change { TargetInvestor.count }.by(1)

    target = TargetInvestor.last
    expect(target.investor).to eq(@investor2)
    expect(target.email).to eq(@investor2.email)
    expect(target.stage).to include('respond')

    expect do
      post external_api_v1_message_path, params: {
        From: @investor2.email,
        To: @founder.email,
        'stripped-text': 'sorry, not interested right now.'
      }
      expect(response).to be_success
    end.to_not change { TargetInvestor.count }

    target = TargetInvestor.last
    expect(target.investor).to eq(@investor2)
    expect(target.email).to eq(@investor2.email)
    expect(target.stage).to include('pass')
  end
end