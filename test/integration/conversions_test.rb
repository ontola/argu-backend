# frozen_string_literal: true

require 'test_helper'

class ConversionsTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:question) do
    create(:question,
           :with_follower,
           :with_motions,
           parent: freetown,
           options: {
             creator: create(:profile_direct_email)
           })
  end
  let(:motion) do
    create(:motion,
           :with_arguments,
           :with_votes,
           parent: freetown)
  end
  let(:cover_photo) { create(:image_object, about: motion, used_as: :cover_photo) }
  let(:question_motion) do
    create(:motion,
           :with_arguments,
           :with_votes,
           parent: question)
  end
  let(:question_content) do
    motion_blog_post
    question_nested_comment
  end
  let(:question_blog_post) do
    create(:blog_post, parent: question, happening_attributes: {happened_at: Time.current})
  end
  let(:question_comment) { create(:comment, parent: question) }
  let(:question_nested_comment) { create(:comment, parent: question, in_reply_to_id: question_comment.uuid) }
  let(:motion_content) do
    motion_blog_post
    motion_nested_comment
    argument_comment
    argument_nested_comment
    cover_photo
  end
  let(:motion_blog_post) do
    create(:blog_post, parent: motion, happening_attributes: {happened_at: Time.current})
  end
  let(:motion_comment) { create(:comment, parent: motion) }
  let(:motion_nested_comment) { create(:comment, parent: motion, in_reply_to_id: motion_comment.uuid) }
  let(:argument_comment) { create(:comment, parent: motion.arguments.first) }
  let(:argument_nested_comment) do
    create(:comment, parent: motion.arguments.first, in_reply_to_id: argument_comment.uuid)
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should post convert motion' do
    sign_in staff
    motion_content

    record = motion
    argument = argument_comment.parent_model
    vote_count = motion.default_vote_event.children.where(owner_type: 'Vote').count
    assert vote_count.positive?,
           'no votes to test'

    assert_differences([['Motion.count', -1], ['Question.count', 1], ['VoteEvent.count', -1], ['Argument.count', -6],
                        ['Vote.count', -6], ['Activity.count', 1], ['BlogPost.count', 0],
                        ['MediaObject.count', 0], ['Comment.count', 6], ['Edge.count', -7]]) do
      post conversions_iri_path(record),
           params: {
             conversion: {
               klass: 'questions'
             }
           }
    end

    record = Edge.find_by!(uuid: record.uuid)
    argument = Edge.find_by!(uuid: argument.uuid)
    argument_comment.reload
    argument_nested_comment.reload

    assert_redirected_to record.iri_path

    assert Motion.where(id: record.id).empty?
    assert_equal Question, record.class
    assert_equal Forum, record.parent.class
    assert_equal Comment, argument.class

    # Test direct relations
    assert_equal motion_blog_post.parent_model, Question.last
    assert_equal motion_nested_comment.parent_model, Question.last
    assert_equal motion_nested_comment.parent_comment, motion_comment
    assert_equal argument_comment.parent_model, Question.last
    assert_equal argument_comment.parent_comment, argument
    assert_equal argument_nested_comment.parent_comment, argument_comment

    # Activity for Create, Publish and Convert
    assert_equal 3, record.activities.count
  end

  test 'staff should post convert question motion' do
    sign_in staff

    record = question_motion

    assert_differences([['Motion.count', -1], ['VoteEvent.count', -1], ['Question.count', 1], ['Argument.count', -6],
                        ['Vote.count', -6], ['Activity.count', 1], ['BlogPost.count', 0],
                        ['Comment.count', 6], ['Edge.count', -7]]) do
      post conversions_iri_path(record),
           params: {
             conversion: {
               klass: 'questions'
             }
           }
    end

    record = Edge.find_by!(uuid: record.uuid)
    assert_redirected_to record.iri_path

    assert Motion.where(id: question_motion.id).empty?
    assert_equal Question, record.class
    assert_equal Forum, record.parent.class
  end

  test 'staff should post convert question' do
    sign_in staff
    question_content

    record = question

    assert_differences([['Question.count', -1], ['Motion.count', -3], ['VoteEvent.count', -3],
                        ['Activity.count', 1], ['BlogPost.count', 0], ['Comment.count', 4], ['Edge.count', -3]]) do
      post conversions_iri_path(record),
           params: {
             conversion: {
               klass: 'motions'
             }
           }
    end

    record = Edge.find_by!(uuid: record.uuid)

    assert_redirected_to record.iri_path

    assert Question.where(id: record.id).empty?
    assert_equal Motion, record.class
    assert_equal Forum, record.parent.class

    # Test direct relations
    assert_equal question_blog_post.reload.parent_model, Motion.last

    # Activity for Create, Publish and Convert
    assert_equal 3, record.activities.count
  end
end
