# frozen_string_literal: true

module Argu
  module TestHelpers
    module TestAssertions
      def assert_not_a_user
        assert_equal true, assigns(:_not_a_user_caught)
      end

      def assert_not_authorized
        assert_equal true, assigns(:_not_authorized_caught)
      end

      def assert_email_sent(count: 1, skip_sidekiq: false) # rubocop:disable Metrics/AbcSize
        unless skip_sidekiq
          assert_equal count, Sidekiq::Worker.jobs.select { |j| j['class'] == 'SendEmailWorker' }.count
          SendEmailWorker.drain
        end

        assert_requested :post, expand_service_url(:email, '/argu/email/spi/emails'), times: count
        last_match = WebMock::RequestRegistry
                       .instance
                       .requested_signatures
                       .hash
                       .keys
                       .detect { |r| r.uri.to_s == expand_service_url(:email, '/argu/email/spi/emails') }
        WebMock.reset!
        last_match
      end

      def expect_ontola_action(redirect:)
        action = "actions/redirect?#{{location: redirect}.to_param}" if redirect
        expect(response.headers['Exec-Action']).to(include(action))
      end

      def expect_triple(subject, predicate, object, graph = NS::LL[:supplant])
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
