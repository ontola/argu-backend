# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Conversions', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  let(:new_path) { url_for([:new, subject, :conversion, only_path: true]) }
  let(:non_existing_new_path) { url_for([:new, :edge, :conversion, edge_id: -1, only_path: true]) }
  let(:create_path) { url_for([subject, :conversions, only_path: true]) }
  let(:non_existing_create_path) { url_for([:edge, :conversions, edge_id: -1, only_path: true]) }
  let(:invalid_create_params) { {conversion: {klass: 'arguments'}} }
  let(:created_resource_path) { url_for([subject.reload.owner, only_path: true]) }
  let(:expect_post_create_failed_html) { expect_post_create_unauthorized_html }
  let(:expect_post_create_failed_serializer) { expect_post_create_unauthorized_serializer }
  let(:authorized_user) { staff }
  let(:create_failed_path) { created_resource_path }

  context 'motion to question' do
    subject { motion.edge }
    let(:create_params) { {conversion: {klass: 'questions'}} }
    let(:create_differences) { [['Question.count', 1], ['Motion.count', -1], ['Activity.loggings.count', 1]] }
    it_behaves_like 'get new'
    it_behaves_like 'post create'
  end

  context 'question_to_motion' do
    subject { question.edge }
    let(:create_params) { {conversion: {klass: 'motions'}} }
    let(:create_differences) do
      [
        ['Question.count', -1],
        ['Motion.where("question_id IS NOT NULL").count', -1],
        ['Motion.where("question_id IS NULL").count', 1],
        ['Activity.loggings.count', 1]
      ]
    end
    it_behaves_like 'get new'
    it_behaves_like 'post create'
  end
end
