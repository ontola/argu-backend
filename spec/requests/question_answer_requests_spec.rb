# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'QuestionAnswers', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  let(:new_path) { new_question_answer_path(question_answer: {question_id: question.id}) }
  let(:non_existing_new_path) { new_question_answer_path(question_answer: {question_id: -99}) }
  let(:parent_path) { question_path(question) }
  let(:create_path) { question_answers_path }
  let(:create_params) { {question_answer: {question_id: question.id, motion_id: forum_motion.id}} }
  let(:non_existing_create_path) { create_path }
  let(:non_existing_create_params) { {question_answer: {question_id: -99, motion_id: forum_motion.id}} }
  let(:invalid_create_params) { {question_answer: {question_id: question.id, motion_id: -99}} }
  let(:create_differences) { [['question.motions.count', 1], ['Motion.where(question_id: nil).count', -1]] }
  let(:no_differences) { [['question.motions.count', 0], ['Motion.where(question_id: nil).count', 0]] }
  let(:created_resource_path) { parent_path }
  let(:expect_post_create_failed_html) { expect_success }

  subject { nil }
  it_behaves_like 'get new'
  it_behaves_like 'post create'
end
