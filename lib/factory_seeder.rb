# frozen_string_literal: true

require 'factory_girl'
require 'factory_girl_rails'
require 'argu/test_helpers/test_helper_methods'
require 'argu/test_helpers/trait_listener'
require 'sidekiq/testing'

module FactoryGirl
  class Evaluator
    def passed_in?(name)
      # https://groups.google.com/forum/?fromgroups#!searchin/factory_girl/stack$20level/factory_girl/MyYKwbq76d0/JrKJZCgaXMIJ
      # Also check that we didn't pass in nil.
      __override_names__.include?(name) && send(name)
    end
  end
end

class FactorySeeder
  extend FactoryGirl::Syntax::Methods
  extend Argu::TestHelpers::TestHelperMethods::InstanceMethods
end
