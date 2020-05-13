# frozen_string_literal: true

module Argu
  module TestHelpers
    module TestAssertions
      def requested_iri
        RDF::URI(request.original_url.sub(".#{request.format.symbol}", ''))
      end

      def assert_disabled_form(iri: requested_iri, error: 'This action is currently not available')
        assert_response 200
        expect_triple(iri, NS::SCHEMA.actionStatus, NS::ONTOLA[:DisabledActionStatus])
        expect_triple(iri, NS::SCHEMA.error, error)
      end

      def assert_enabled_form(iri: requested_iri)
        assert_response 200
        expect_triple(iri, NS::SCHEMA.actionStatus, NS::SCHEMA[:PotentialActionStatus])
      end

      def assert_not_a_user
        assert_response 401
      end

      def assert_not_authorized
        assert_response 403
      end

      def assert_email_sent(count: 1, skip_sidekiq: false, root: :argu) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        unless skip_sidekiq
          assert_equal count, Sidekiq::Worker.jobs.select { |j| j['class'] == 'SendEmailWorker' }.count
          SendEmailWorker.drain
        end

        assert_requested :post, expand_service_url(:email, "/#{root}/email/spi/emails"), times: count
        last_match = WebMock::RequestRegistry
                       .instance
                       .requested_signatures
                       .hash
                       .keys
                       .detect { |r| r.uri.to_s == expand_service_url(:email, "/#{root}/email/spi/emails") }
        WebMock.reset!
        last_match
      end

      def assert_redis_resource_count(count, opts)
        assert_equal count, RedisResource::Relation.where(opts).count
      end

      def expect_ontola_action(redirect: nil, snackbar: nil, reload: nil)
        if redirect
          expect_header('Exec-Action', "actions/redirect?#{{location: redirect, reload: reload}.compact.to_param}")
        end
        expect_header('Exec-Action', "actions/snackbar?#{{text: snackbar}.to_param}") if snackbar

        expect_ontola_action_count([redirect, snackbar].compact.size)
      end

      def expect_ontola_action_count(count)
        if count.zero?
          assert_nil response.headers['Exec-Action']
        else
          assert_equal count, response.headers['Exec-Action'].count("\n"), response.headers['Exec-Action']
        end
      end

      def expect_header(key, value)
        expect(response.headers[key]).to(include(value))
      end

      def expect_resource_type(type, iri: requested_iri)
        expect_triple(iri, RDF[:type], type)
      end

      def expect_triple(subject, predicate, object, graph = NS::LL[:supplant])
        statement = RDF::Statement(subject, predicate, object, graph_name: graph)
        match = rdf_body.query(statement)
        assert match.present?, "Expected to find #{statement} in\n#{response.body}"
        match
      end

      def refute_triple(subject, predicate, object, graph = nil)
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
