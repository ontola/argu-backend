# frozen_string_literal: true
require 'test_helper'

class ConversionsTest < ActionDispatch::IntegrationTest
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
             creator: create(:profile_direct_email)
           })
  end
  let(:project_question) do
    create(:question,
           :with_follower,
           parent: project.edge,
           options: {
             creator: create(:profile_direct_email)
           })
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
  let(:motion_blog_post) do
    create(:blog_post, parent: motion.edge, happening_attributes: {happened_at: DateTime.current})
  end
  let(:question_blog_post) do
    create(:blog_post, parent: question.edge, happening_attributes: {happened_at: DateTime.current})
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should not get convert motion' do
    sign_in user
    get new_edge_conversion_url(motion.edge)
    assert_not_authorized
    assert_response 403
  end

  test 'user should not post convert motion' do
    sign_in user
    post edge_conversions_path(motion.edge),
         params: {
           conversion: {
             klass: 'questions'
           }
         }
    assert_not_authorized
    assert_response 403
  end

  test 'user should not get convert question' do
    sign_in user
    get new_edge_conversion_url(question.edge)
    assert_not_authorized
    assert_response 403
  end

  test 'user should not post convert question' do
    sign_in user
    post edge_conversions_path(question.edge),
         params: {
           conversion: {
             klass: 'motions'
           }
         }
    assert_not_authorized
    assert_response 403
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should not get convert project' do
    sign_in staff

    get new_edge_conversion_path(project.edge)
    assert_response 422
  end

  test 'staff should not post convert project' do
    sign_in staff

    post edge_conversions_path(project.edge),
         params: {
           conversion: {
             klass: 'questions'
           }
         }
    assert_response 422
  end

  test 'staff should not get convert argument' do
    sign_in staff

    get new_edge_conversion_path(argument.edge)
    assert_response 422
  end

  test 'staff should not post convert argument' do
    sign_in staff

    post edge_conversions_path(argument.edge),
         params: {
           conversion: {
             klass: 'questions'
           }
         }
    assert_response 422
  end

  test 'staff should get convert motion' do
    sign_in staff

    get new_edge_conversion_path(motion.edge)
    assert_response 200
  end

  test 'staff should post convert motion' do
    sign_in staff
    motion_blog_post

    edge = motion.edge
    vote_count = motion.default_vote_event.edge.children.where(owner_type: 'Vote').count
    assert vote_count.positive?,
           'no votes to test'

    assert_differences([['Motion.count', -1], ['Question.count', 1], ['VoteEvent.count', -1], ['Argument.count', -6],
                        ['Vote.count', -6], ['Edge.count', -13], ['Activity.count', 1], ['BlogPost.count', 0]]) do
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
    assert_equal 0, Vote.where(voteable_id: motion.id, voteable_type: 'Motion').count
    assert_equal 0, Activity.where(trackable: motion).count

    # Activity for Create, Publish and Convert
    assert_equal 3, edge.owner.activities.count
  end

  test 'staff should post convert question motion' do
    sign_in staff
    motion_blog_post

    edge = question_motion.edge

    assert_differences([['Motion.count', -1], ['VoteEvent.count', -1], ['Question.count', 1], ['Argument.count', -6],
                        ['Vote.count', -6], ['Edge.count', -13], ['Activity.count', 1], ['BlogPost.count', 0]]) do
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
    motion_blog_post

    edge = project_motion.edge

    assert_differences([['Motion.count', -1], ['VoteEvent.count', -1], ['Question.count', 1], ['Argument.count', -6],
                        ['Vote.count', -6], ['Edge.count', -13], ['Activity.count', 1], ['BlogPost.count', 0]]) do
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
    question_blog_post

    edge = question.edge

    assert_differences([['Question.count', -1], ['Motion.count', 1], ['VoteEvent.count', 1], ['Edge.count', 1],
                        ['Activity.count', 1], ['BlogPost.count', 0]]) do
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
    assert_equal 0, Activity.where(trackable: question).count
    assert_equal question_blog_post.reload.blog_postable_type, 'Motion'

    # Activity for Create, Publish and Convert
    assert_equal 3, edge.owner.activities.count
  end

  test 'staff should post convert project question' do
    sign_in staff
    question_blog_post

    edge = project_question.edge

    assert_differences([['Question.count', -1], ['Motion.count', 1], ['VoteEvent.count', 1], ['Vote.count', 0],
                        ['Edge.count', 1], ['Activity.count', 1], ['BlogPost.count', 0]]) do
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
