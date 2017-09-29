# frozen_string_literal: true

require 'test_helper'

class CommentsTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects
  define_public_source

  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:argument) do
    create(:argument,
           :with_follower,
           parent: motion.edge,
           creator: create(:profile_direct_email))
  end
  let(:subject) do
    create(:comment,
           publisher: creator,
           parent: argument.edge)
  end

  ####################################
  # As creator
  ####################################
  test 'creator should not delete wipe own comment twice affecting counter caches' do
    sign_in creator

    assert_equal 1, subject.parent_model.children_count(:comments)

    assert_differences([['subject.parent_model.reload.children_count(:comments)', -1],
                        ['creator.profile.comments.count', -1]]) do
      assert_difference 'Comment.trashed.count', 0 do
        delete destroy_comment_path(subject)
      end
      assert_differences([['Comment.trashed.count', 1], ['Comment.where(body: "").count', 1]]) do
        delete destroy_comment_path(
          subject,
          destroy: 'true'
        )
      end
    end

    assert_redirected_to argument_path(argument)
  end

  ####################################
  # As staff
  ####################################
  test 'staff should not delete wipe other comment twice affecting counter caches' do
    sign_in staff

    assert_equal 1, subject.parent_model.children_count(:comments)

    assert_differences([['subject.parent_model.reload.children_count(:comments)', -1],
                        ['creator.profile.comments.count', -1]]) do
      assert_difference 'Comment.trashed.count', 1 do
        delete destroy_comment_path(subject)
      end
      assert_difference 'Comment.where(body: "").count', 1 do
        delete destroy_comment_path(
          subject,
          destroy: 'true'
        )
      end
    end

    assert_redirected_to argument_path(argument)
  end
end
