# frozen_string_literal: true
module Argu
  module TestHelpers
    module TestAssertions
      def assert_analytics_collected(category = nil, action = nil, label = nil, **options)
        category ||= options[:category]
        action ||= options[:action]
        label ||= options[:label]
        assert_requested :post, 'https://ssl.google-analytics.com/collect' do |req|
          el = CGI.parse(req.body)['el'].first if label
          ea = CGI.parse(req.body)['ea'].first if action
          ec = CGI.parse(req.body)['ec'].first.to_s
          category == ec && (action ? action == ea : true) && (label ? label.to_s == el : true)
        end
      end

      def assert_analytics_not_collected
        assert_not_requested(
          stub_request(:post, 'https://ssl.google-analytics.com/collect')
            .with(body: /(&ea=(?!sign_in)){1}/)
        )
      end

      def assert_not_a_user
        assert_equal true, assigns(:_not_a_user_caught)
      end

      def assert_not_authorized
        assert_equal true, assigns(:_not_authorized_caught)
      end

      def assert_relationship(key, size = 1)
        relationships = JSON.parse(response.body)['data']['relationships']
        assert relationships.keys.include?(key), "#{key} is not in relationships"

        unless size == 1 && relationships[key]['data'].is_a?(Hash)
          assert_equal relationships[key]['data']&.size || 0, size, 'Size of relationship is incorrect'
        end
        relationships[key]
      end

      def assert_included(id)
        if id.is_a?(Array)
          assert_not_empty id, 'No entries given'
          id.each do |single|
            assert_included(single)
          end
          return
        end

        id = ['https://', Rails.application.config.host, id].join
        assert JSON.parse(response.body)['included'].any? { |included| included['id'] == id },
               "#{id} is not included"
      end

      def assert_not_included(id)
        if id.is_a?(Array)
          assert_not_empty id, 'No entries given'
          id.each do |single|
            assert_not_included(single)
          end
          return
        end

        id = ['https://', Rails.application.config.host, id].join
        assert_not JSON.parse(response.body)['included'].any? { |included| included['id'] == id },
                   "#{id} is included"
      end
    end
  end
end
