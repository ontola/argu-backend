# frozen_string_literal: true
require 'test_helper'

class ConversionsControllerTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:project) do
    create(:project,
           :with_follower,
           parent: freetown.edge)
  end
  let(:question) do
    create(:question,
           :with_follower,
           parent: freetown.edge,
           options: {
             creator: create(:profile_direct_email)})
  end
  let(:project_question) do
    create(:question,
           :with_follower,
           parent: project.edge,
           options: {
             creator: create(:profile_direct_email)})
  end
  let(:motion) do
    create(:motion,
           :with_arguments,
           :with_votes,
           parent: freetown.edge)
  end
  let(:question_motion) do
    create(:motion,
           :with_arguments,
           :with_votes,
           parent: question.edge)
  end
  let(:project_motion) do
    create(:motion,
           :with_arguments,
           :with_votes,
           parent: project.edge)
  end
  let(:argument) do
    create(:argument, parent: motion.edge)
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should not get convert motion' do
    sign_in user
    get new_edge_conversion_url(motion.edge)
    assert_not_authorized
    assert_redirected_to root_path
  end

  test 'user should not post convert motion' do
    sign_in user
    post edge_conversions_path(motion.edge),
         params: {
           conversion: {
             klass: 'questions'
           }
         }
    assert_redirected_to root_path
  end

  test 'user should not get convert question' do
    sign_in user
    get new_edge_conversion_url(question.edge)
    assert_not_authorized
    assert_redirected_to root_path
  end

  test 'user should not post convert question' do
    sign_in user
    post edge_conversions_path(question.edge),
         params: {
           conversion: {
             klass: 'motions'
           }
         }
    assert_redirected_to root_path
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should not get convert project' do
    sign_in staff

    get new_edge_conversion_path(project.edge)
    assert_response 302
    assert_not_authorized
  end

  test 'staff should not post convert project' do
    sign_in staff

    post edge_conversions_path(project.edge),
         params: {
           conversion: {
             klass: 'questions'
           }
         }
    assert_response 302
    assert_not_authorized
  end

  test 'staff should not get convert argument' do
    sign_in staff

    get new_edge_conversion_path(argument.edge)
    assert_response 302
    assert_not_authorized
  end

  test 'staff should not post convert argument' do
    sign_in staff

    post edge_conversions_path(argument.edge),
         params: {
           conversion: {
             klass: 'questions'
           }
         }
    assert_response 302
    assert_not_authorized
  end

  test 'staff should get convert motion' do
    sign_in staff

    get new_edge_conversion_path(motion.edge)
    assert_response 200
  end

  test 'staff should post convert motion' do
    sign_in staff

    edge = motion.edge
    vote_count = motion.votes.count
    assert vote_count > 0,
           'no votes to test'

    assert_differences([['Motion.count', -1], ['Question.count', 1], ['Argument.count', -6],
                        ['Vote.count', 0], ['Edge.count', -6], ['Activity.count', 1]]) do
      post edge_conversions_path(motion.edge),
           params: {
             conversion: {
              klass: 'questions'
             }
           }
    end

    assert_redirected_to edge.reload.owner

    assert Motion.where(id: motion.id).empty?
    assert_equal Question, edge.owner.class
    assert_equal Forum, edge.parent.owner.class

    # Test direct relations
    assert_equal 0, Argument.where(motion_id: motion.id).count
    assert_equal 0, Vote.where(voteable: motion).count
    assert_equal 0, Activity.where(trackable: motion).count

    assert_equal vote_count, edge.owner.votes.count
    assert edge.owner.votes.none? { |v| v.edge.parent != edge }
    # Activity for Create and Convert
    assert_equal 2, edge.owner.activities.count
  end

  test 'staff should post convert question motion' do
    sign_in staff

    edge = question_motion.edge

    assert_differences([['Motion.count', -1], ['Question.count', 1], ['Argument.count', -6],
                        ['Vote.count', 0], ['Edge.count', -6], ['Activity.count', 1]]) do
      post edge_conversions_path(question_motion.edge),
           params: {
             conversion: {
               klass: 'questions'
             }
           }
    end

    assert_redirected_to edge.reload.owner

    assert Motion.where(id: question_motion.id).empty?
    assert_equal Question, edge.owner.class
    assert_equal Forum, edge.parent.owner.class
  end

  test 'staff should post convert project motion' do
    sign_in staff

    edge = project_motion.edge

    assert_differences([['Motion.count', -1], ['Question.count', 1], ['Argument.count', -6],
                        ['Vote.count', 0], ['Edge.count', -6], ['Activity.count', 1]]) do
      post edge_conversions_path(project_motion.edge),
           params: {
             conversion: {
               klass: 'questions'
             }
           }
    end

    assert_redirected_to edge.reload.owner

    assert Motion.where(id: project_motion.id).empty?
    assert_equal Question, edge.owner.class
    assert_equal Project, edge.parent.owner.class
  end

  test 'staff should get convert question' do
    sign_in staff

    get new_edge_conversion_path(question.edge)
    assert_response 200
  end

  test 'staff should post convert question' do
    sign_in staff

    edge = question.edge

    create(:vote, parent: question.edge)
    vote_count = question.votes.count
    assert vote_count > 0,
           'no votes to test'

    assert_differences([['Question.count', -1], ['Motion.count', 1], ['Vote.count', 0],
                        ['Edge.count', 0], ['Activity.count', 1]]) do
      post edge_conversions_path(question.edge),
           params: {
             conversion: {
               klass: 'motions'
             }
           }
    end

    assert_redirected_to edge.reload.owner

    assert Question.where(id: question.id).empty?
    assert_equal Motion, edge.owner.class
    assert_equal Forum, edge.parent.owner.class

    # Test direct relations
    assert_equal 0, Vote.where(voteable: question).count
    assert_equal 0, Activity.where(trackable: question).count

    assert_equal vote_count, edge.owner.votes.count
    assert edge.owner.votes.none? { |v| v.edge.parent != edge }
    # Activity for Create and Convert
    assert_equal 2, edge.owner.activities.count
  end

  test 'staff should post convert project question' do
    sign_in staff

    edge = project_question.edge

    assert_differences([['Question.count', -1], ['Motion.count', 1], ['Vote.count', 0],
                        ['Edge.count', 0], ['Activity.count', 1]]) do
      post edge_conversions_path(project_question.edge),
           params: {
             conversion: {
               klass: 'motions'
             }
           }
    end

    assert_redirected_to edge.reload.owner

    assert Question.where(id: project_question.id).empty?
    assert_equal Motion, edge.owner.class
    assert_equal Project, edge.parent.owner.class
  end
end
