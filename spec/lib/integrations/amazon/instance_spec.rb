require "rails_helper"

describe Integrations::Amazon::Instance do
  before do
    @integration = Integrations::Amazon::Instance
  end

  it 'should return correct module key' do
    expect(@integration.mkey).to eq('amazon')
  end


end