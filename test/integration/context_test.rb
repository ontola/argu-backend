# frozen_string_literal: true
require 'test_helper'

class ContextTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects
  let(:forum) { freetown }
  let(:question) { create(:question, parent: forum.edge) }
  let(:motion) { create(:motion, parent: question.edge) }
  let(:argument) { create(:argument, parent: motion.edge) }
  let(:comment) { create(:comment, parent: argument.edge) }
  let!(:vote) { create(:vote, parent: motion.default_vote_event.edge, voter: user.profile, for: :pro) }

  test 'major content models should have a context' do
    %i(question motion argument comment).each do |kind|
      get polymorphic_path(send(kind), format: :json_api)

      assert_response 200
      body = JSON.parse(response.body)
      assert_equal "argu:#{kind.capitalize}", body['data']['attributes']['@type']
      assert_equal 'schema:text',
                   body['data']['attributes']['@context']['content'],
                   "#{kind} has no context or content"
    end
  end

  test 'vote should have a context model' do
    sign_in vote.voter.profileable

    get polymorphic_path([motion, :show, :vote], format: :json_api)

    assert_response 200
    body = JSON.parse(response.body)
    assert_equal 'argu:Vote', body['data']['attributes']['@type']
    assert_equal 'schema:option',
                 body['data']['attributes']['@context']['for'],
                 'vote has no context or content'
    kv_pair = body['data']['attributes']['@context'].find { |_, v| v == 'schema:option' }
    assert_equal vote.for,
                 body['data']['attributes'][kv_pair[0]],
                 'vote values are set incorrectly'
  end
end
