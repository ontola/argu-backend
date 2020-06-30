# frozen_string_literal: true

require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  define_freetown
  let(:motion) { create(:motion, parent: freetown) }
  let(:argument) { create(:pro_argument, :with_comments, parent: motion) }
  let(:blog_post) do
    create(:blog_post, :with_comments, parent: motion)
  end
  let(:comment) { create(:comment, parent: argument) }

  ####################################
  # Show
  ####################################
  test 'should get show comment' do
    get :show, params: {format: :json_api, id: comment.fragment, root_id: argu.url}
    assert_response 200

    expect_relationship('parent')
    expect_relationship('creator')
  end

  ####################################
  # Index for Argument
  ####################################
  test 'should get index comments of argument' do
    get :index, params: {format: :json_api, root_id: argu.url, pro_argument_id: argument.fragment}
    assert_response 200

    expect_relationship('part_of')

    expect_default_view
    expect_included(collection_iri(argument, :comments, page: 1))
    expect_not_included(argument.comments.trashed.map(&:iri))
  end

  test 'should get index comments of argument with page=1' do
    get :index,
        params: {format: :json_api, root_id: argu.url, pro_argument_id: argument.fragment, type: 'paginated', page: 1}
    assert_response 200

    expect_relationship('collection')

    expect_view_members(primary_resource, argument.comments.untrashed.count)
    expect_not_included(argument.comments.trashed.map(&:iri))
  end

  ####################################
  # Index for BlogPost
  ####################################
  test 'should get index comments of blog_post' do
    get :index, params: {format: :json_api, root_id: argu.url, blog_post_id: blog_post.fragment}
    assert_response 200

    expect_relationship('part_of')

    expect_default_view
    expect_included(collection_iri(blog_post, :comments, page: 1))
    expect_not_included(blog_post.comments.trashed.map(&:iri))
  end

  test 'should get index comments of blog_post with page=1' do
    get :index,
        params: {format: :json_api, root_id: argu.url, blog_post_id: blog_post.fragment, type: 'paginated', page: 1}
    assert_response 200

    expect_relationship('collection')

    expect_view_members(primary_resource, blog_post.comments.untrashed.count)
    expect_not_included(blog_post.comments.trashed.map(&:iri))
  end
end
