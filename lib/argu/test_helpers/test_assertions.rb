# frozen_string_literal: true
module Argu
  module TestHelpers
    module TestAssertions
      # Runs assert_difference with a number of conditions and varying difference
      # counts.
      #
      # @example
      #   assert_differences([['Model1.count', 2], ['Model2.count', 3]])
      #
      def assert_differences(expression_array, message = nil, &block)
        b = block.send(:binding)
        before = expression_array.map { |expr| eval(expr[0], b) }

        yield

        expression_array.each_with_index do |pair, i|
          e = pair[0]
          difference = pair[1]
          error = "#{e.inspect} didn't change by #{difference}"
          error = "#{message}\n#{error}" if message
          assert_equal(before[i] + difference, eval(e, b), error)
        end
      end

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
    end
  end
end
