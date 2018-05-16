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
    get :show, params: {format: :json_api, id: comment.edge.fragment, root_id: argu.url}
    assert_response 200

    expect_relationship('partOf', 1)
    expect_relationship('creator', 1)
  end

  ####################################
  # Index for Argument
  ####################################
  test 'should get index comments of argument' do
    get :index, params: {format: :json_api, root_id: argu.url, pro_argument_id: argument.edge.fragment}
    assert_response 200

    expect_relationship('partOf', 1)

    expect_relationship('viewSequence', 1)
    expect_included(collection_iri(argument, :comments, page: 1, type: 'paginated'))
    expect_included(argument.comments(:untrashed).map(&:iri))
    expect_not_included(argument.comments(:trashed).map(&:iri))
  end

  test 'should get index comments of argument with page=1' do
    get :index, params: {format: :json_api, root_id: argu.url, pro_argument_id: argument.edge.fragment, page: 1}
    assert_response 200

    expect_relationship('partOf', 1)

    member_sequence = expect_relationship('memberSequence', 1)
    assert_equal expect_included(member_sequence['data']['id'])['relationships']['members']['data'].count,
                 argument.comments(:untrashed).count
    expect_included(argument.comments(:untrashed).map(&:iri))
    expect_not_included(argument.comments(:trashed).map(&:iri))
  end

  ####################################
  # Index for BlogPost
  ####################################
  test 'should get index comments of blog_post' do
    get :index, params: {format: :json_api, root_id: argu.url, blog_post_id: blog_post.edge.fragment}
    assert_response 200

    expect_relationship('partOf', 1)

    expect_relationship('viewSequence', 1)
    expect_included(collection_iri(blog_post, :comments, page: 1, type: 'paginated'))
    expect_included(blog_post.comments(:untrashed).map(&:iri))
    expect_not_included(blog_post.comments(:trashed).map(&:iri))
  end

  test 'should get index comments of blog_post with page=1' do
    get :index, params: {format: :json_api, root_id: argu.url, blog_post_id: blog_post.edge.fragment, page: 1}
    assert_response 200

    expect_relationship('partOf', 1)

    member_sequence = expect_relationship('memberSequence', 1)
    assert_equal expect_included(member_sequence['data']['id'])['relationships']['members']['data'].count,
                 blog_post.comments(:untrashed).count
    expect_included(blog_post.comments(:untrashed).map(&:iri))
    expect_not_included(blog_post.comments(:trashed).map(&:iri))
  end
end
