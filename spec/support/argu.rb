RSpec.configure do |config|
  config.before(:suite) do
    Setting.set('user_cap', -1)
  end
end
