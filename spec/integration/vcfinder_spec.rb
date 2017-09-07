require 'rails_helper'

RSpec.describe 'vcfinder request', type: :request do
  before do
    @company = FactoryGirl.create(:company, :verified, :with_external)
    @founder = FactoryGirl.create(:founder, companies: [@company])
    @target_investor = FactoryGirl.create(:target_investor, founder: @founder)

    sign_in @founder
  end

  it 'renders the react component' do
    get external_vcfinder_root_path
    assert_select 'div[data-react-class=VCFinder]'
  end

  it 'can fetch the target investors' do
    get external_api_v1_target_investors_path
    expect(response.parsed_body.length).to eq(1)
  end
end