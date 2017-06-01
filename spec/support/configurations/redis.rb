RSpec.configure do |config|
  config.after(:each) do
    $redis.flushall
  end
end