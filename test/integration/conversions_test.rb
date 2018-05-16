# frozen_string_literal: true

require 'test_helper'

class ConversionsTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:question) do
    create(:question,
           :with_follower,
           :with_motions,
           parent: freetown.edge,
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
  let(:cover_photo) { create(:image_object, about: motion, used_as: :cover_photo) }
  let(:question_motion) do
    create(:motion,
           :with_arguments,
           :with_votes,
           parent: question.edge)
  end
  let(:question_content) do
    motion_blog_post
    question_nested_comment
  end
  let(:question_blog_post) do
    create(:blog_post, parent: question.edge, happening_attributes: {happened_at: Time.current})
  end
  let(:question_comment) { create(:comment, parent: question.edge) }
  let(:question_nested_comment) { create(:comment, parent: question.edge, parent_id: question_comment.id) }
  let(:motion_content) do
    motion_blog_post
    motion_nested_comment
    argument_comment
    cover_photo
  end
  let(:motion_blog_post) do
    create(:blog_post, parent: motion.edge, happening_attributes: {happened_at: Time.current})
  end
  let(:motion_comment) { create(:comment, parent: motion.edge) }
  let(:motion_nested_comment) { create(:comment, parent: motion.edge, parent_id: motion_comment.id) }
  let(:argument_comment) { create(:comment, parent: motion.arguments.first.edge) }

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should post convert motion' do
    sign_in staff
    motion_content

    edge = motion.edge
    vote_count = motion.default_vote_event.edge.children.where(owner_type: 'Vote').count
    assert vote_count.positive?,
           'no votes to test'

    assert_differences([['Motion.count', -1], ['Question.count', 1], ['VoteEvent.count', -1], ['Argument.count', -6],
                        ['Vote.count', -9], ['Activity.count', 1], ['BlogPost.count', 0],
                        ['MediaObject.count', 0], ['Comment.count', 5], ['Edge.count', -11]]) do
      post conversions_iri_path(edge.owner.canonical_iri(only_path: true)),
           params: {
             conversion: {
               klass: 'questions'
             }
           }
    end

    assert_redirected_to edge.reload.owner.iri_path

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

    edge = question_motion.edge

    assert_differences([['Motion.count', -1], ['VoteEvent.count', -1], ['Question.count', 1], ['Argument.count', -6],
                        ['Vote.count', -9], ['Activity.count', 1], ['BlogPost.count', 0],
                        ['Comment.count', 6], ['Edge.count', -10]]) do
      post conversions_iri_path(edge.owner.canonical_iri(only_path: true)),
           params: {
             conversion: {
               klass: 'questions'
             }
           }
    end

    assert_redirected_to edge.reload.owner.iri_path

    assert Motion.where(id: question_motion.id).empty?
    assert_equal Question, edge.owner.class
    assert_equal Forum, edge.parent.owner.class
  end

  test 'staff should post convert question' do
    sign_in staff
    question_content

    edge = question.edge

    assert_differences([['Question.count', -1], ['Motion.count', -3], ['VoteEvent.count', -3],
                        ['Activity.count', 1], ['BlogPost.count', 0], ['Comment.count', 3], ['Edge.count', -4]]) do
      post conversions_iri_path(edge.owner.canonical_iri(only_path: true)),
           params: {
             conversion: {
               klass: 'motions'
             }
           }
    end

    assert_redirected_to edge.reload.owner.iri_path

    assert Question.where(id: question.id).empty?
    assert_equal Motion, edge.owner.class
    assert_equal Forum, edge.parent.owner.class

    # Test direct relations
    assert_equal 0, Activity.where(trackable: question).count
    assert_equal question_blog_post.reload.blog_postable_type, 'Motion'

    # Activity for Create, Publish and Convert
    assert_equal 3, edge.owner.activities.count
  end
end
