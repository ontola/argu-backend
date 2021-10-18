# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Conversions', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  let(:new_path) { new_iri(conversions_iri(subject).path).path }
  let(:create_path) { subject.collection_iri(:conversions).path }
  let(:invalid_create_params) { {conversion: {klass_iri: Argument.iri}} }
  let(:created_resource_path) { Edge.find_by(uuid: subject.uuid).iri.path }
  let(:expect_post_create_failed_serializer) { expect_post_create_unauthorized_serializer }
  let(:authorized_user) { staff }
  let(:create_failed_path) { created_resource_path }
  let(:expect_get_new_unauthorized_serializer) { expect_unauthorized }
  let(:expect_get_new_guest_serializer) { expect_unauthorized }
  let(:expect_post_create_serializer) { expect_success }
  let(:expect_post_create_json_api) { expect(response.code).to eq('302') }

  context 'motion to question' do
    subject { motion }

    let(:create_params) { {conversion: {klass_iri: Question.iri}} }
    let(:create_differences) { {'Question.count' => 1, 'Motion.count' => -1, 'Activity.count' => 1} }

    it_behaves_like 'get new', skip: %i[non_existing]
    it_behaves_like 'post create', skip: %i[non_existing]
  end

  context 'question_to_motion' do
    subject { question }

    let(:create_params) { {conversion: {klass_iri: Motion.iri}} }
    let(:create_differences) do
      {
        'Question.count' => -1,
        "Motion.where(id: #{question.id}).count" => 1,
        "Motion.where('id != #{question.id}').count" => -1,
        'Activity.count' => 1
      }
    end

    it_behaves_like 'get new', skip: %i[non_existing]
    it_behaves_like 'post create', skip: %i[non_existing]
  end
end
