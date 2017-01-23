# frozen_string_literal: true
require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  define_freetown
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:argument) { create(:argument, :with_comments, parent: motion.edge) }
  let(:blog_post) { create(:blog_post, :with_comments, parent: motion.edge, happened_at: DateTime.current) }
  let(:comment) { create(:comment, parent: argument.edge) }

  ####################################
  # Show
  ####################################
  test 'should get show comment' do
    get :show, params: {format: :json_api, id: comment}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('creator', 1)
  end

  ####################################
  # Index for Argument
  ####################################
  test 'should get index comments of argument' do
    get :index, params: {format: :json_api, argument_id: argument.id}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('members', 0)

    assert_relationship('views', 1)
    assert_included("/a/#{argument.id}/c?page=1")
    assert_included(argument.comment_threads.untrashed.map { |c| "/comments/#{c.id}" })
    assert_not_included(argument.comment_threads.trashed.map { |c| "/comments/#{c.id}" })
  end

  test 'should get index comments of argument with page=1' do
    get :index, params: {format: :json_api, argument_id: argument.id, page: 1}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('views', 0)

    assert_relationship('members', argument.comment_threads.untrashed.count)
    assert_included(argument.comment_threads.untrashed.map { |c| "/comments/#{c.id}" })
    assert_not_included(argument.comment_threads.trashed.map { |c| "/comments/#{c.id}" })
  end

  ####################################
  # Index for BlogPost
  ####################################
  test 'should get index comments of blog_post' do
    get :index, params: {format: :json_api, blog_post_id: blog_post.id}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('members', 0)

    assert_relationship('views', 1)
    assert_included("/posts/#{blog_post.id}/c?page=1")
    assert_included(blog_post.comment_threads.untrashed.map { |c| "/comments/#{c.id}" })
    assert_not_included(blog_post.comment_threads.trashed.map { |c| "/comments/#{c.id}" })
  end

  test 'should get index comments of blog_post with page=1' do
    get :index, params: {format: :json_api, blog_post_id: blog_post.id, page: 1}
    assert_response 200

    assert_relationship('parent', 1)
    assert_relationship('views', 0)

    assert_relationship('members', blog_post.comment_threads.untrashed.count)
    assert_included(blog_post.comment_threads.untrashed.map { |c| "/comments/#{c.id}" })
    assert_not_included(blog_post.comment_threads.trashed.map { |c| "/comments/#{c.id}" })
  end
end
