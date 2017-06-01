require "rails_helper"

describe Integrations::Ebay::Instance do
  before do
    @integration = Integrations::Ebay::Instance
    @integration_obj = Integrations::Ebay::Instance.new({})
  end

  it 'should return correct module key' do
    expect(@integration.mkey).to eq('ebay')
  end

end