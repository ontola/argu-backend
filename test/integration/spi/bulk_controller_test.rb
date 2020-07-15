# frozen_string_literal: true

require 'test_helper'

module SPI
  class BulkControllerTest < ActionDispatch::IntegrationTest
    define_page
    let(:freetown) { create(:forum, parent: argu, public_grant: 'initiator', url: 'freetown', locale: :nl) }
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
             public_grant: 'initiator',
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

    def bulk_resources
      [
        {include: true, iri: current_actor_iri},
        {include: true, iri: motion1.iri},
        {include: false, iri: motion2.iri},
        {include: true, iri: holland_motion1.iri},
        {include: false, iri: holland_motion2.iri},
        {include: true, iri: hidden_vote1.iri},
        {include: false, iri: hidden_vote2.iri},
        {include: false, iri: 'https://example.com'}
      ]
    end

    def bulk_resources_demogemeente
      [
        {include: true, iri: demogemeente.iri},
        {include: true, iri: dg_current_actor_iri},
        {include: true, iri: dg_motion1.iri},
        {include: false, iri: 'https://example.com'}
      ]
    end

    def bulk_responses(opts = {})
      {
        current_actor_iri => {cache: 'private', status: 200, include: true},
        motion1.iri => {cache: 'public', status: 200, include: true},
        motion2.iri => {cache: 'public', status: 200, include: false},
        holland_motion1.iri => {cache: 'no-cache', status: 200, include: true},
        holland_motion2.iri => {cache: 'no-cache', status: 200, include: false},
        hidden_vote1.iri => {cache: 'private', status: 403, include: true},
        hidden_vote2.iri => {cache: 'private', status: 403, include: false},
        'https://example.com' => {cache: 'private', status: 404, include: false}
      }.merge(opts)
    end

    def bulk_responses_demogemeente
      {
        demogemeente.iri => {cache: 'no-cache', status: 200, include: true},
        dg_current_actor_iri => {cache: 'private', status: 200, include: true},
        dg_motion1.iri => {cache: 'public', status: 200, include: true},
        'https://example.com' => {cache: 'private', status: 404, include: false}
      }
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def bulk_request(page: argu, resources: bulk_resources, responses: bulk_responses)
      domain = page.iri_prefix.split('/')
      host! domain[0]
      tenant_prefix = domain[1].present? ? "/#{domain[1]}" : ''
      post "#{tenant_prefix}#{spi_bulk_path}", params: {resources: resources}

      assert_response 200

      response = JSON.parse(body).map(&:with_indifferent_access)
      assert_equal resources.count, response.count

      responses.each do |iri, expectation|
        resource = response.detect { |r| r[:iri] == iri }
        assert_equal iri.to_s, resource[:iri]
        assert_equal expectation[:status], resource[:status], "#{iri} should be #{expectation[:status]}"
        assert_equal expectation[:cache], resource[:cache], "#{iri} should be #{expectation[:cache]}"
        type_statement = "\"#{iri}\",\"#{RDF[:type]}\""
        method = expectation[:include] ? :assert_includes : :refute_includes
        send(method, resource[:body] || '', type_statement)
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def current_actor
      CurrentActor.new(user: user)
    end

    def current_actor_iri
      "http://#{argu.iri_prefix}/c_a"
    end

    def dg_current_actor_iri
      "http://#{demogemeente.iri_prefix}/c_a"
    end

    def user_responses(opts = {})
      bulk_responses(
        {
          holland_motion1.iri => {cache: 'private', status: 403, include: false},
          holland_motion2.iri => {cache: 'private', status: 403, include: false}
        }.merge(opts)
      )
    end
  end
end
