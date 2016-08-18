# frozen_string_literal: true
require 'argu/test_helpers/automated_tests/configuration'

module Argu
  module TestHelpers
    module AutomatedTests
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def define_tests
          tests = yield
          tests.each do |action, action_values|
            method = action_methods[action]
            action_values[:test_cases].each do |test_case|
              case_suffix = test_case[:case_suffix]

              test_case[:user_types].each do |user_type, results|
                should_string = results[:should] ? 'should' : 'should not'

                test "#{user_type} #{should_string} #{method} #{action}#{case_suffix}" do
                  sign_in send(user_type) unless user_type == :guest || user_type.nil?

                  send("general_#{action}", {results: results}.merge(test_case[:options] || {}))

                  ((test_case[:asserts] || []) + (results[:asserts] || []))&.each do |assertion|
                    if %i(update create destroy trash untrash).include?(action)
                      assertion = assertion.gsub('resource', "assigns(:#{action}_service).resource")
                    end
                    assert eval(assertion), assertion
                  end
                end
              end
            end
          end

          ((action_methods.keys - tests.keys) &
            name.sub('Test', '').constantize.instance_methods).each do |a|
            warn "No tests for #{a} in #{name}"
          end
        end

        def define_test(hash, action, options = {})
          options[:user_types] ||= user_types[action]
          hash[action] = {test_cases: []} unless hash.key?(action)
          hash[action][:test_cases].append(options)
          hash
        end

        def action_methods
          @action_methods ||= Argu::TestHelpers::AutomatedTests.config.action_methods
        end

        def fixture_file_upload(path, mime_type = nil, binary = false)
          path = File.join(File.expand_path('test/fixtures/'), path)
          Rack::Test::UploadedFile.new(path, mime_type, binary)
        end

        def user_types
          @user_types ||= Argu::TestHelpers::AutomatedTests.config.user_types
        end
      end
    end
  end
end
