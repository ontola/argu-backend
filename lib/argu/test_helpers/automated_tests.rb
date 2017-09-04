# frozen_string_literal: true

require 'argu/test_helpers/automated_tests/configuration'
require 'argu/test_helpers/automated_tests/asserts'
include Argu::TestHelpers::AutomatedTests::Asserts

module Argu
  module TestHelpers
    module AutomatedTests
      def self.included(base)
        base.extend(ClassMethods)
      end

      def automated_test_assertions(action, test_case, _user_type, results)
        ((test_case[:asserts] || []) + (results[:asserts] || []))&.each do |assertion|
          if %i(update create destroy trash untrash).include?(action)
            assertion = assertion.gsub('resource', "assigns(:#{action}_service).resource.reload")
          end
          assert eval(assertion), assertion
        end
      end

      def perform_automated_test(action, test_case, user_type, results, method)
        if %i(member non_member).include?(user_type)
          freetown.grants.where(group_id: Group::PUBLIC_ID).destroy_all
          public_source.grants.where(group_id: Group::PUBLIC_ID).destroy_all if respond_to?(:public_source)
          create_forum(public_grant: 'member')
        end
        if user_type == :spectator
          freetown.grants.find_by(group_id: Group::PUBLIC_ID).spectator!
          public_source.grants.find_by(group_id: Group::PUBLIC_ID).spectator! if respond_to?(:public_source)
        end

        sign_in send(user_type) unless user_type == :guest || user_type.nil?

        send("general_#{action}", {results: results}.merge(test_case[:options] || {}))

        automated_test_assertions(action, test_case, user_type, results)

        get root_path if user_type == :staff && method != :get
      end

      module ClassMethods
        def define_tests
          tests = yield
          tests.each do |action, action_values|
            method = action_methods[action]
            action_values[:test_cases].each do |test_case|
              suffix = test_case[:suffix]

              test_case[:user_types].each do |user_type, results|
                should_string = results[:should] ? 'should' : 'should not'

                test "#{user_type} #{should_string} #{method} #{action}#{suffix}" do
                  perform_automated_test(action, test_case, user_type, results, method)
                end
              end
            end
          end
          warn_untested_methods(tests)
        end

        def define_test(hash, action, options = {})
          options[:user_types] ||= block_given? ? yield : user_types[action]
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

        def warn_untested_methods(tests)
          ((action_methods.keys - tests.keys) &
            name.sub('Test', '').singularize.constantize.instance_methods).each do |a|
            warn "No tests for #{a} in #{name}"
          end
        end
      end
    end
  end
end
