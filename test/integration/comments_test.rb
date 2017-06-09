# frozen_string_literal: true
require 'test_helper'

class CommentsTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects
  define_public_source

  let(:cairo_member) { create_member(cairo) }
  let(:member) { create_member(freetown) }
  let(:question) { create(:question, parent: freetown.edge) }
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
  let(:blog_post) do
    create(:blog_post,
           :with_follower,
           parent: motion.edge,
           edge_attributes: {argu_publication_attributes: {publish_type: 'direct'}},
           happening_attributes: {happened_at: DateTime.current},
           creator: create(:profile_direct_email))
  end
  let(:blog_post_subject) { create(:comment, publisher: creator, parent: blog_post.edge) }
  let(:motion_subject) { create(:comment, publisher: creator, parent: motion.edge) }
  let(:question_subject) { create(:comment, publisher: creator, parent: question.edge) }
  let(:linked_record) { create(:linked_record, source: public_source, iri: 'https://iri.test/resource/1') }

  define_cairo
  let(:cairo_motion) { create(:motion, parent: cairo.edge) }
  let(:cairo_argument) { create(:argument, parent: cairo_motion.edge) }
  let(:cairo_subject) do
    create(:comment,
           creator: member.profile,
           parent: cairo_argument.edge)
  end

  define_cairo('second_cairo')
  let(:second_cairo_motion) { create(:motion, parent: second_cairo.edge) }
  let(:second_cairo_argument) { create(:argument, parent: second_cairo_motion.edge) }
  let(:second_cairo_subject) do
    create(:comment,
           creator: member.profile,
           parent: second_cairo_argument.edge)
  end

  def edit_path(record)
    url_for([:edit, record.parent_model, record])
  end

  def update_path(record)
    url_for([record.parent_model, record])
  end

  def destroy_path(record)
    url_for([record.parent_model, record, destroy: true])
  end

  def self.assert_redirect_new_user_argument
    'assert_redirected_to new_user_session_path(r: new_argument_comment_path(argument_id: '\
    "argument.id, comment: {body: 'Just å UTF-8 comment.'}, confirm: true))"
  end

  def self.assert_redirect_new_user_blog_post
    'assert_redirected_to new_user_session_path(r: new_blog_post_comment_path(blog_post_id: '\
    "blog_post.id, comment: {body: 'Just å UTF-8 comment.'}, confirm: true))"
  end

  def self.assert_redirect_new_user_motion
    'assert_redirected_to new_user_session_path(r: new_motion_comment_path(motion_id: '\
    "motion.id, comment: {body: 'Just å UTF-8 comment.'}, confirm: true))"
  end

  def self.assert_redirect_new_user_linked_record
    'assert_redirected_to new_user_session_path(r: new_linked_record_comment_path(linked_record_id: '\
    "linked_record.id, comment: {body: 'Just å UTF-8 comment.'}, confirm: true))"
  end

  def self.assert_redirect_new_user_question
    'assert_redirected_to new_user_session_path(r: new_question_comment_path(question_id: '\
    "question.id, comment: {body: 'Just å UTF-8 comment.'}, confirm: true))"
  end

  def self.assert_redirect_argument
    'assert_redirected_to argument_path(send(test_case[:options]&.try(:[], :record) || :subject).parent_model, '\
    'anchor: send(test_case[:options]&.try(:[], :record) || :subject).identifier)'
  end

  def self.assert_redirect_blog_post
    'assert_redirected_to blog_post_path(send(test_case[:options]&.try(:[], :record) || :subject).parent_model, '\
    'anchor: send(test_case[:options]&.try(:[], :record) || :subject).identifier)'
  end

  def self.assert_redirect_motion
    'assert_redirected_to motion_comments_path(send(test_case[:options]&.try(:[], :record) || :subject).parent_model)'
  end

  def self.assert_redirect_question
    'assert_redirected_to question_comments_path(send(test_case[:options]&.try(:[], :record) || :subject).parent_model)'
  end

  def self.assert_has_content
    'assert_select "#comment_body", "C"'
  end

  define_tests do
    hash = {}
    define_test(hash, :new, suffix: ' for argument', options: {parent: :argument})
    define_test(hash, :new, suffix: ' for blog_post', options: {parent: :blog_post})
    options = {
      parent: :argument,
      analytics: stats_opt('comments', 'create_success'),
      attributes: {body: 'Just å UTF-8 comment.'}
    }
    define_test(hash, :create, suffix: ' for argument', options: options) do
      user_types[:create].merge(
        guest: exp_res(response: 302, asserts: [assert_not_a_user, assert_redirect_new_user_argument], analytics: false)
      )
    end
    options = {
      parent: :linked_record,
      analytics: stats_opt('comments', 'create_success'),
      attributes: {body: 'Just å UTF-8 comment.'}
    }
    define_test(hash, :create, suffix: ' for linked_record', options: options) do
      user_types[:create].except(:member).merge(
        guest: exp_res(
          response: 302,
          asserts: [assert_not_a_user, assert_redirect_new_user_linked_record],
          analytics: false
        )
      )
    end
    options = {
      parent: :motion,
      analytics: stats_opt('comments', 'create_success'),
      attributes: {body: 'Just å UTF-8 comment.'}
    }
    define_test(hash, :create, suffix: ' for motion', options: options) do
      user_types[:create].merge(
        guest: exp_res(response: 302, asserts: [assert_not_a_user, assert_redirect_new_user_motion], analytics: false)
      )
    end
    options = {
      parent: :question,
      analytics: stats_opt('comments', 'create_success'),
      attributes: {body: 'Just å UTF-8 comment.'}
    }
    define_test(hash, :create, suffix: ' for question', options: options) do
      user_types[:create].merge(
        guest: exp_res(response: 302, asserts: [assert_not_a_user, assert_redirect_new_user_question], analytics: false)
      )
    end
    options = {
      parent: :blog_post,
      analytics: stats_opt('comments', 'create_success'),
      attributes: {body: 'Just å UTF-8 comment.'}
    }
    define_test(hash, :create, suffix: ' for blog_post', options: options) do
      user_types[:create].merge(
        guest: exp_res(response: 302,
                       asserts: [assert_not_a_user, assert_redirect_new_user_blog_post],
                       analytics: false)
      )
    end
    # @todo body is lost on errorneous post
    options = {
      parent: :argument,
      analytics: stats_opt('comments', 'create_failed'),
      attributes: {body: 'C'}
    }
    define_test(hash, :create, suffix: ' erroneous', options: options) do
      {manager: exp_res(response: 302, asserts: [])}
    end
    define_test(hash, :show, asserts: [assert_redirect_argument]) do
      {
        guest: exp_res(response: 302, should: true),
        user: exp_res(response: 302, should: true),
        member: exp_res(response: 302, should: true),
        manager: exp_res(response: 302, should: true),
        super_admin: exp_res(response: 302, should: true),
        staff: exp_res(response: 302, should: true)
      }
    end
    define_test(hash, :show, suffix: ' for blog_post', options: {record: :blog_post_subject}) do
      {user: exp_res(response: 302, should: true, asserts: [assert_redirect_blog_post])}
    end
    define_test(hash, :show, suffix: ' for motion', options: {record: :motion_subject}) do
      {user: exp_res(response: 302, should: true, asserts: [assert_redirect_motion])}
    end
    define_test(hash, :show, suffix: ' for question', options: {record: :question_subject}) do
      {user: exp_res(response: 302, should: true, asserts: [assert_redirect_question])}
    end
    define_test(hash, :show, suffix: ' cairo', options: {record: :cairo_subject}) do
      {
        guest: exp_res(response: 403),
        user: exp_res(response: 403),
        member: exp_res(response: 403),
        manager: exp_res(response: 403),
        super_admin: exp_res(response: 403),
        cairo_member: exp_res(response: 302, should: true, asserts: [assert_redirect_argument]),
        staff: exp_res(response: 302, should: true, asserts: [assert_redirect_argument])
      }
    end
    define_test(hash, :show, suffix: ' cairo', options: {record: :second_cairo_subject}) do
      {cairo_member: exp_res(response: 403)}
    end
    define_test(hash, :show, suffix: ' non-existent', options: {record: 'none'}) do
      {user: exp_res(response: 404)}
    end
    define_test(hash, :edit) do
      {
        guest: exp_res(response: 302, asserts: [assert_not_a_user]),
        user: exp_res(asserts: [assert_not_authorized]),
        member: exp_res(asserts: [assert_not_authorized]),
        creator: exp_res(should: true, response: 200),
        manager: exp_res(asserts: [assert_not_authorized]),
        super_admin: exp_res(asserts: [assert_not_authorized]),
        staff: exp_res(asserts: [assert_not_authorized])
      }
    end
    define_test(hash, :update) do
      {
        guest: exp_res(response: 302, asserts: [assert_not_a_user]),
        user: exp_res(asserts: [assert_not_authorized]),
        member: exp_res(asserts: [assert_not_authorized]),
        creator: exp_res(response: 302, should: true),
        manager: exp_res(asserts: [assert_not_authorized]),
        super_admin: exp_res(asserts: [assert_not_authorized]),
        staff: exp_res(asserts: [assert_not_authorized])
      }
    end
    define_test(hash, :update, suffix: ' erroneous', options: {attributes: {body: 'C'}}) do
      {creator: exp_res(response: 200, asserts: [assert_has_content])}
    end
    options = {
      differences: [['Comment.where(body: "")', 1], ['Activity.loggings', 1]],
      analytics: stats_opt('comments', 'destroy_success')
    }
    define_test(hash, :destroy, options: options)
    define_test(hash, :trash, options: {analytics: stats_opt('comments', 'trash_success')})
  end

  ####################################
  # As creator
  ####################################
  test 'creator should not delete wipe own comment twice affecting counter caches' do
    sign_in creator

    assert_equal 1, subject.parent_model.children_count(:comments)

    assert_differences([['subject.parent_model.reload.children_count(:comments)', -1],
                        ['creator.profile.comments.count', -1]]) do
      delete trash_argument_comment_path(subject.parent_model, subject)
      delete destroy_argument_comment_path(
        subject.parent_model,
        subject,
        destroy: 'true'
      )
    end

    assert_redirected_to argument_path(argument, anchor: subject.identifier)
  end

  ####################################
  # As super_admin
  ####################################
  test 'super_admin should not delete wipe other comment twice affecting counter caches' do
    sign_in create_super_admin(freetown)

    assert_equal 1, subject.parent_model.children_count(:comments)

    assert_differences([['subject.parent_model.reload.children_count(:comments)', -1],
                        ['creator.profile.comments.count', -1]]) do
      delete trash_argument_comment_path(subject.parent_model, subject)
      delete destroy_argument_comment_path(
        subject.parent_model,
        subject,
        destroy: 'true'
      )
    end

    assert_redirected_to argument_url(argument, anchor: subject.identifier)
  end
end
