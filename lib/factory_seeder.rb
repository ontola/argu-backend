# frozen_string_literal: true

require 'factory_bot'
require 'factory_bot_rails'
require 'sidekiq/testing'

module FactoryBot
  class Evaluator
    def passed_in?(name)
      # https://groups.google.com/forum/?fromgroups#!searchin/factory_girl/stack$20level/factory_girl/MyYKwbq76d0/JrKJZCgaXMIJ
      # Also check that we didn't pass in nil.
      __override_names__.include?(name) && send(name)
    end
  end
end

class FactorySeeder
  extend FactoryBot::Syntax::Methods
  extend Argu::TestHelpers::TestHelperMethods::InstanceMethods
end
