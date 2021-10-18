# frozen_string_literal: true

require 'test_helper'

class CommentsTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects

  let(:motion) { create(:motion, parent: freetown) }
  let(:argument) do
    create(:pro_argument,
           :with_follower,
           parent: motion,
           creator: create(:profile_direct_email))
  end
  let(:subject) do
    create(:comment,
           publisher: creator,
           parent: argument)
  end

  ####################################
  # As user
  ####################################
  test 'user should post create comment for comment' do
    sign_in user
    subject
    assert_difference('Comment.count' => 1,
                      'Property.where(predicate: "https://argu.co/ns/core#inReplyTo").count' => 1) do
      post subject.collection_iri(:comments),
           params: {comment: {body: 'My opinion'}},
           headers: argu_headers(accept: :json)
    end

    assert_response 201

    assert_equal Comment.last.parent_comment, subject
    assert_equal Comment.last.parent, argument
  end

  test 'user should post create comment with latlon from filter' do
    sign_in initiator

    filter = {
      NS.argu[:pdfPositionX] => 1,
      NS.argu[:pdfPositionY] => 2,
      NS.argu[:pdfPage] => 3
    }
    motion

    assert_difference('Comment.count' => 1, 'Activity.count' => 1) do
      post motion.collection_iri(:comments, type: :paginated, filter: filter),
           headers: argu_headers(accept: :nq),
           params: {comment: default_create_attributes}

      assert_response(:created)
    end

    assert_equal 1, Comment.last.pdf_position_x
    assert_equal 2, Comment.last.pdf_position_y
    assert_equal 3, Comment.last.pdf_page
  end
  ####################################
  # As creator
  ####################################
  test 'creator should not delete wipe own comment twice affecting counter caches' do
    sign_in creator

    assert_equal 1, subject.parent.children_count(:comments)

    assert_difference('subject.parent.reload.children_count(:comments)' => -1,
                      'creator.profile.comments.count' => -1) do
      assert_difference 'Comment.trashed.count', 0 do
        delete subject
      end
      assert_difference('Comment.trashed.count' => 1, 'Comment.where(description: "").count' => 1) do
        delete subject.iri(destroy: 'true')
      end
    end

    assert_response :success
  end

  ####################################
  # As staff
  ####################################
  test 'staff should not delete wipe other comment twice affecting counter caches' do
    sign_in staff

    assert_equal 1, subject.parent.children_count(:comments)

    assert_difference('subject.parent.reload.children_count(:comments)' => -1,
                      'creator.profile.comments.count' => -1) do
      assert_difference 'Comment.trashed.count', 1 do
        delete subject
      end
      assert_difference 'Comment.where(description: "").count', 1 do
        delete subject.iri(destroy: 'true')
      end
    end

    assert_response :success
  end
end
