# frozen_string_literal: true

require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  define_freetown
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:argument) { create(:argument, :with_comments, parent: motion.edge) }
  let(:blog_post) do
    create(:blog_post, :with_comments, parent: motion.edge, happening_attributes: {happened_at: Time.current})
  end
  let(:comment) { create(:comment, parent: argument.edge) }

  ####################################
  # Show
  ####################################
  test 'should get show comment' do
    get :show, params: {format: :json_api, id: comment}
    assert_response 200

    expect_relationship('parent', 1)
    expect_relationship('creator', 1)
  end

  ####################################
  # Index for Argument
  ####################################
  test 'should get index comments of argument' do
    get :index, params: {format: :json_api, argument_id: argument.id}
    assert_response 200

    expect_relationship('parent', 1)

    expect_relationship('viewSequence', 1)
    expect_included(argu_url("/a/#{argument.id}/c", page: 1, type: 'paginated'))
    expect_included(argument.comment_threads.untrashed.map { |c| argu_url("/comments/#{c.id}") })
    expect_not_included(argument.comment_threads.trashed.map { |c| argu_url("/comments/#{c.id}") })
  end

  test 'should get index comments of argument with page=1' do
    get :index, params: {format: :json_api, argument_id: argument.id, page: 1}
    assert_response 200

    expect_relationship('parent', 1)

    member_sequence = expect_relationship('memberSequence', 1)
    assert_equal expect_included(member_sequence['data']['id'])['relationships']['members']['data'].count,
                 argument.comment_threads.untrashed.count
    expect_included(argument.comment_threads.untrashed.map { |c| argu_url("/comments/#{c.id}") })
    expect_not_included(argument.comment_threads.trashed.map { |c| argu_url("/comments/#{c.id}") })
  end

  ####################################
  # Index for BlogPost
  ####################################
  test 'should get index comments of blog_post' do
    get :index, params: {format: :json_api, blog_post_id: blog_post.id}
    assert_response 200

    expect_relationship('parent', 1)

    expect_relationship('viewSequence', 1)
    expect_included(argu_url("/posts/#{blog_post.id}/c", page: 1, type: 'paginated'))
    expect_included(blog_post.comment_threads.untrashed.map { |c| argu_url("/comments/#{c.id}") })
    expect_not_included(blog_post.comment_threads.trashed.map { |c| argu_url("/comments/#{c.id}") })
  end

  test 'should get index comments of blog_post with page=1' do
    get :index, params: {format: :json_api, blog_post_id: blog_post.id, page: 1}
    assert_response 200

    expect_relationship('parent', 1)

    member_sequence = expect_relationship('memberSequence', 1)
    assert_equal expect_included(member_sequence['data']['id'])['relationships']['members']['data'].count,
                 blog_post.comment_threads.untrashed.count
    expect_included(blog_post.comment_threads.untrashed.map { |c| argu_url("/comments/#{c.id}") })
    expect_not_included(blog_post.comment_threads.trashed.map { |c| argu_url("/comments/#{c.id}") })
  end
end
