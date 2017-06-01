require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:each) do | example |
    if example.metadata[:web] == :disable
      WebMock.disable_net_connect!
    end
  end
end