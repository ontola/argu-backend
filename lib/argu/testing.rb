# frozen_string_literal: true

require 'testing/assertions'
require 'testing/common_objects'
require 'testing/r_spec_helpers'
require 'testing/role_methods'
require 'testing/test_mocks'

# Shared helper method across TestUnit and RSpec
module Argu
  module Testing
    def self.included(base)
      base.send(:include, Assertions)
      base.send(:include, CommonObjects)
      base.send(:include, RSpecHelpers)
      base.send(:include, RoleMethods)
      base.send(:include, TestMocks)
    end
  end
end
