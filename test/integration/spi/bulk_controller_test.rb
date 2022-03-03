# frozen_string_literal: true

require 'test_helper'
require 'support/thread_helper'

module SPI
  class BulkControllerTest < ActionDispatch::IntegrationTest
    include ThreadHelper

    define_page
    let(:freetown) { create(:forum, parent: argu, initial_public_grant: 'initiator', url: 'freetown', locale: :nl) }
    let(:holland) { create(:forum, parent: argu, url: 'holland', locale: :nl) }
    let(:guest_user) { create_guest_user }
    let(:motion1) { create(:motion, parent: freetown) }
    let(:motion2) { create(:motion, parent: freetown) }
    let(:holland_motion1) { create(:motion, parent: holland) }
    let(:holland_motion2) { create(:motion, parent: holland) }
    let(:hidden_vote1) { create(:vote, parent: motion1.default_vote_event, publisher: voter) }
    let(:hidden_vote2) { create(:vote, parent: motion2.default_vote_event, publisher: voter) }
    let(:user) { create(:user) }
    let(:spectator) { create_spectator(holland) }
    let(:administrator) { create_administrator(argu) }
    let(:voter) { create(:user, show_feed: false) }

    let(:demogemeente) { create(:page, url: 'demogemeente', iri_prefix: 'demogemeente.nl') }
    let(:demogemeente_forum) do
      create(:forum,
             parent: demogemeente,
             initial_public_grant: 'initiator',
             url: 'demogemeente',
             locale: :nl)
    end
    let(:dg_motion1) { create(:motion, parent: demogemeente_forum) }

    ####################################
    # As Guest
    ####################################
    test 'guest should post bulk request' do
      sign_in guest_user

      bulk_request(responses: user_responses)
    end

    test 'guest should post bulk for demogemeente' do
      sign_in guest_user

      bulk_request(page: demogemeente,
                   resources: bulk_resources_demogemeente,
                   responses: bulk_responses_demogemeente)
    end

    test 'guest should post bulk request public resources' do
      sign_in guest_user
      reindex_tree

      bulk_request(
        resources: public_resources,
        responses: public_responses
      )
    end

    test 'guest should post bulk request ontology data' do
      sign_in guest_user

      bulk_request(
        resources: ontology_resources,
        responses: ontology_responses
      )
    end

    test 'guest should post bulk escape injection' do
      sign_in guest_user

      bulk_request(
        resources: injection_resources,
        responses: injection_responses
      )
      assert_not(response.body.include?('</script>'))
      assert_not(response.body.include?('<script>'))
    end

    test 'guest should post bulk request for linked_record' do
      sign_in guest_user

      bulk_request(resources: linked_record_resources, responses: linked_record_responses)
    end

    test 'guest should post bulk request for whitelisted linked_record' do
      linked_record_stub(dg_motion1)
      argu.update(allowed_external_sources: [demogemeente.iri])
      sign_in guest_user

      bulk_request(resources: linked_record_resources, responses: whitelisted_linked_record_responses)

      statements = JSON.parse(body).first['body'].split("\n").map { |s| JSON.parse(s) }
      linked_iri = "http://argu.localtest/argu/resource?iri=#{CGI.escape(dg_motion1.iri)}"
      included_records = statements.map(&:first).uniq.sort.filter { |subject| subject.start_with?('http') }
      expected_includes = ActsAsTenant.with_tenant(demogemeente) do
        [
          linked_iri,
          dg_motion1.iri.to_s,
          dg_motion1.argument_columns_iri.to_s
        ]
      end
      assert_equal(included_records, expected_includes)
      body.include?("\\\"#{linked_iri}\\\",\\\"#{NS.owl.sameAs}\\\",\\\"#{dg_motion1.iri}\\\"")
      body.include?("\\\"#{dg_motion1.iri}\\\",\\\"#{NS.owl.sameAs}\\\",\\\"#{linked_iri}\\\"")
    end

    ####################################
    # As User
    ####################################

    test 'user should post bulk request' do
      sign_in user

      bulk_request(responses: user_responses)
    end

    ####################################
    # As Voter
    ####################################
    test 'voter should post bulk request' do
      sign_in voter

      bulk_request(responses: user_responses(
        hidden_vote1.iri => {cache: 'private', status: 200, include: true},
        hidden_vote2.iri => {cache: 'private', status: 200, include: false}
      ))
    end

    ####################################
    # As Holland Spectator
    ####################################
    test 'spectator should post bulk request' do
      sign_in spectator

      bulk_request
    end

    ####################################
    # As Administrator
    ####################################
    test 'administrator should post bulk request' do
      sign_in administrator

      bulk_request
    end

    private

    def bulk_resources # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      [
        {include: true, iri: current_actor_iri},
        {include: true, iri: motion1.iri},
        {include: false, iri: motion2.iri},
        {include: true, iri: holland_motion1.iri},
        {include: false, iri: holland_motion2.iri},
        {include: true, iri: hidden_vote1.iri},
        {include: false, iri: hidden_vote2.iri},
        {include: false, iri: 'https://example.com'},
        {include: true, iri: "#{argu.iri}/wrong_iri"},
        {include: true, iri: "#{argu.iri}/cable"},
        {include: true, iri: resource_iri(motion1.activities.last, root: argu)},
        {include: true, iri: resource_iri(holland_motion1.activities.last, root: argu)},
        {include: true, iri: "#{argu.iri}/u/search"},
        {include: true, iri: "#{argu.iri}/u/search?q=1"}
      ]
    end

    def bulk_responses(**opts) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      {
        current_actor_iri => {cache: 'private', status: 200, include: true},
        motion1.iri => {cache: 'public', status: 200, include: true},
        motion2.iri => {cache: 'public', status: 200, include: false},
        holland_motion1.iri => {cache: 'no-cache', status: 200, include: true},
        holland_motion2.iri => {cache: 'no-cache', status: 200, include: false},
        hidden_vote1.iri => {cache: 'private', status: 403, include: true},
        hidden_vote2.iri => {cache: 'private', status: 403, include: false},
        'https://example.com' => {cache: 'private', status: 404, include: false},
        "#{argu.iri}/wrong_iri" => {cache: 'private', status: 404, include: true},
        "#{argu.iri}/cable" => {cache: 'private', status: 404, include: true},
        resource_iri(motion1.activities.last, root: argu) => {cache: 'public', status: 200, include: true},
        resource_iri(holland_motion1.activities.last, root: argu) => {cache: 'no-cache', status: 200, include: true},
        "#{argu.iri}/u/search" => {cache: 'private', status: 403, include: true},
        "#{argu.iri}/u/search?q=1" => {cache: 'private', status: 403, include: true}
      }.merge(opts)
    end

    def bulk_resources_demogemeente
      [
        {include: true, iri: demogemeente.iri},
        {include: true, iri: dg_current_actor_iri},
        {include: true, iri: dg_motion1.iri},
        {include: false, iri: 'https://example.com'}
      ]
    end

    def bulk_responses_demogemeente
      {
        demogemeente.iri => {cache: 'public', status: 200, include: true},
        dg_current_actor_iri => {cache: 'private', status: 200, include: true},
        dg_motion1.iri => {cache: 'public', status: 200, include: true},
        'https://example.com' => {cache: 'private', status: 404, include: false}
      }
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def bulk_request(page: argu, resources: bulk_resources, responses: bulk_responses)
      domain = page.iri_prefix.split('/')
      host! domain[0]
      tenant_prefix = domain[1].present? ? "/#{domain[1]}" : ''

      thread_stub(->(*args) { args.first == 'argu' }) do
        post "#{tenant_prefix}#{spi_bulk_path}", params: {resources: resources}
      end

      assert_response 200

      response = JSON.parse(body).map(&:with_indifferent_access)
      assert_equal resources.count, response.count

      responses.each do |iri, expectation|
        resource = response.detect { |r| r[:iri] == iri }
        raise("No expected response available for #{iri}. Found #{response.pluck(:iri)}") if resource.blank?

        assert_equal iri.to_s, resource[:iri]
        assert_equal expectation[:status], resource[:status], "#{iri} should be #{expectation[:status]}"
        assert_equal expectation[:cache], resource[:cache], "#{iri} should be #{expectation[:cache]}"
        type_statement = "\"#{expectation[:iri] || iri}\",\"#{RDF[:type]}\""
        type_statement += ",\"#{expectation[:type]}" if expectation.key?(:type)
        method = expectation[:include] ? :assert_includes : :refute_includes
        send(method, resource[:body] || '', type_statement)
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    def current_actor
      CurrentActor.new(user: user)
    end

    def current_actor_iri
      "http://#{argu.iri_prefix}/c_a"
    end

    def dg_current_actor_iri
      "http://#{demogemeente.iri_prefix}/c_a"
    end

    def injection_resources
      [
        {include: true, iri: LinkedRails.iri(path: 'argu', query: '</script><script>')},
        {include: true, iri: LinkedRails.iri(path: 'argu/.bla', query: '</script><script>')},
        {include: true, iri: LinkedRails.iri(query: '</script><script>')}
      ]
    end

    def injection_responses(**opts) # rubocop:disable Metrics/MethodLength
      {
        LinkedRails.iri(path: 'argu', query: '%3C/script%3E%3Cscript%3E') => {
          cache: 'public',
          status: 200,
          include: true,
          iri: LinkedRails.iri(path: 'argu')
        },
        LinkedRails.iri(path: 'argu/.bla', query: '%3C/script%3E%3Cscript%3E') => {
          cache: 'private',
          status: 404,
          include: true
        },
        LinkedRails.iri(query: '%3C/script%3E%3Cscript%3E') => {cache: 'private', status: 404, include: false}
      }.merge(opts)
    end

    def linked_record_resources
      [
        {include: true, iri: dg_motion1.iri}
      ]
    end

    def linked_record_responses(**opts)
      {
        dg_motion1.iri => {cache: 'private', status: 404, include: false}
      }.merge(opts)
    end

    def linked_record_stub(record)
      stub_request(:get, record.iri).to_return(
        status: 200,
        body: linked_record_stub_body(record)
      )
    end

    def linked_record_stub_body(record)
      serializer_options = RDF::Serializers::Renderers.transform_opts(
        {include: record&.try(:preview_includes)},
        {}
      )

      ActsAsTenant.with_tenant(demogemeente) do
        RDF::Serializers.serializer_for(record).new(record, serializer_options).send(:render_hndjson)
      end
    end

    def whitelisted_linked_record_responses(**opts)
      {
        dg_motion1.iri => {cache: 'no-cache', status: 200, include: true}
      }.merge(opts)
    end

    def ontology_resources
      [
        {include: true, iri: NS.argu[:Motion]},
        {include: true, iri: NS.argu[:markAsImportant]}
      ]
    end

    def ontology_responses(**opts)
      {
        NS.argu[:Motion] => {cache: 'public', status: 200, include: true, type: RDF::RDFS.Class},
        NS.argu[:markAsImportant] => {cache: 'public', status: 200, include: true, type: RDF.Property}
      }.merge(opts)
    end

    def public_resources
      [
        {include: true, iri: "#{argu.iri}/search"},
        {include: true, iri: "#{argu.iri}/search?q=1"},
        {include: true, iri: "#{freetown.iri}/search"},
        {include: true, iri: "#{freetown.iri}/search?q=1"},
        {include: true, iri: "#{argu.iri}/ns/core"},
        {include: true, iri: resource_iri(MotionForm.new, root: argu)}
      ]
    end

    def public_responses(**opts)
      {
        "#{argu.iri}/search" => {cache: 'public', status: 200, include: true},
        "#{argu.iri}/search?q=1" => {cache: 'private', status: 200, include: true},
        "#{freetown.iri}/search" => {cache: 'public', status: 200, include: true},
        "#{freetown.iri}/search?q=1" => {cache: 'private', status: 200, include: true},
        "#{argu.iri}/ns/core" => {cache: 'public', status: 200, include: true},
        resource_iri(MotionForm.new, root: argu) => {cache: 'public', status: 200, include: true}
      }.merge(opts)
    end

    def user_responses(**opts)
      bulk_responses(
        **{
          holland_motion1.iri => {cache: 'private', status: 403, include: true},
          holland_motion2.iri => {cache: 'private', status: 403, include: false},
          resource_iri(holland_motion1.activities.last, root: argu) => {cache: 'private', status: 403, include: true}
        }.merge(opts)
      )
    end
  end
end
