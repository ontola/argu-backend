# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Conversions', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  let(:new_path) { new_iri_path(conversions_iri_path(subject.canonical_iri(only_path: true))) }
  let(:non_existing_new_path) do
    new_iri_path(conversions_iri_path(expand_uri_template('edges_iri', id: SecureRandom.uuid, only_path: true)))
  end
  let(:create_path) { collection_iri_path(subject.canonical_iri(only_path: true), :conversions) }
  let(:non_existing_create_path) do
    conversions_iri_path(expand_uri_template('edges_iri', id: SecureRandom.uuid, only_path: true))
  end
  let(:invalid_create_params) { {conversion: {klass: 'arguments'}} }
  let(:created_resource_path) { Edge.find_by(uuid: subject.uuid).iri_path }
  let(:expect_post_create_failed_html) { expect_post_create_unauthorized_html }
  let(:expect_post_create_failed_serializer) { expect_post_create_unauthorized_serializer }
  let(:authorized_user) { staff }
  let(:create_failed_path) { created_resource_path }

  context 'motion to question' do
    subject { motion }
    let(:create_params) { {conversion: {klass: 'questions'}} }
    let(:create_differences) { [['Question.count', 1], ['Motion.count', -1], ['Activity.count', 1]] }
    it_behaves_like 'get new'
    it_behaves_like 'post create'
  end

  context 'question_to_motion' do
    subject { question }
    let(:create_params) { {conversion: {klass: 'motions'}} }
    let(:create_differences) do
      [
        ['Question.count', -1],
        ['Motion.count', -2],
        ['Activity.count', 1]
      ]
    end
    it_behaves_like 'get new'
    it_behaves_like 'post create'
  end
end
