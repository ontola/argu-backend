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

    ####################################
    # As Guest
    ####################################
    test 'guest should post bulk request' do
      sign_in guest_user

      bulk_request(responses: user_responses)
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
        {include: true, iri: motion1.iri},
        {include: false, iri: motion2.iri},
        {include: true, iri: holland_motion1.iri},
        {include: false, iri: holland_motion2.iri},
        {include: true, iri: hidden_vote1.iri},
        {include: false, iri: hidden_vote2.iri},
        {include: false, iri: 'https://example.com'}
      ]
    end

    def bulk_responses(opts = {})
      {
        motion1.iri => {cache: 'public', status: 200, include: true},
        motion2.iri => {cache: 'public', status: 200, include: false},
        holland_motion1.iri => {cache: 'no-cache', status: 200, include: true},
        holland_motion2.iri => {cache: 'no-cache', status: 200, include: false},
        hidden_vote1.iri => {cache: 'private', status: 403, include: true},
        hidden_vote2.iri => {cache: 'private', status: 403, include: false},
        'https://example.com' => {cache: 'private', status: 404, include: false}
      }.merge(opts)
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def bulk_request(resources: bulk_resources, responses: bulk_responses)
      post "/#{argu.url}#{spi_bulk_path}", params: {resources: resources}

      assert_response 200

      response = JSON.parse(body).map(&:with_indifferent_access)
      assert_equal response.count, resources.count

      responses.each do |iri, expectation|
        resource = response.detect { |r| r[:iri] == iri }
        assert_equal resource[:iri], iri.to_s
        assert_equal resource[:status], expectation[:status], "#{iri} should be #{expectation[:status]}"
        assert_equal resource[:cache], expectation[:cache], "#{iri} should be #{expectation[:cache]}"
        type_statement = "\"#{iri}\",\"#{RDF[:type]}\""
        method = expectation[:include] ? :assert_includes : :refute_includes
        send(method, resource[:body] || '', type_statement)
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

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
