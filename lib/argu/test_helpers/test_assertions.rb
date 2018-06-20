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

      def assert_email_sent(count: 1, skip_sidekiq: false)
        unless skip_sidekiq
          assert_equal count, Sidekiq::Worker.jobs.select { |j| j['class'] == 'SendEmailWorker' }.count
          SendEmailWorker.drain
        end

        assert_requested :post, argu_url('/email/spi/emails'), times: count
        last_match = WebMock::RequestRegistry
                       .instance
                       .requested_signatures
                       .hash
                       .keys
                       .detect { |r| r.uri.to_s == argu_url('/email/spi/emails') }
        WebMock.reset!
        last_match
      end

      def expect_triple(subject, predicate, object, graph = nil)
        statement = RDF::Statement(subject, predicate, object, graph_name: graph)
        match = rdf_body.query(statement)
        assert match.present?, "Expected to find #{statement} in\n#{response.body}"
        match
      end

      def expect_no_triple(subject, predicate, object, graph = nil)
        statement = RDF::Statement(subject, predicate, object, graph_name: graph)
        assert_not rdf_body.query([subject, predicate, object, graph]).present?,
                   "Expected not to find #{statement} in\n#{response.body}"
      end

      def expect_sequence(subject, predicate)
        expect_triple(subject, predicate, nil).first.object
      end

      def expect_sequence_member(subject, index, object)
        expect_triple(subject, RDF[:"_#{index}"], object)
        object
      end

      def expect_sequence_size(subject, expected_count)
        count =
          expect_triple(subject, nil, nil)
            .select { |s| s.predicate.to_s.starts_with?('http://www.w3.org/1999/02/22-rdf-syntax-ns#_') }
            .count
        assert_equal expected_count, count
      end

      def rdf_body
        @rdf_body ||= RDF::Graph.new << RDF::Reader
                                          .for(content_type: response.headers['Content-Type'])
                                          .new(response.body)
      end
    end
  end
end
