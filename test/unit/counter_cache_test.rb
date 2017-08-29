# frozen_string_literal: true
require 'test_helper'

class CounterCacheTest < ActiveSupport::TestCase
  define_freetown
  let!(:motion) do
    create(:motion,
           :with_arguments,
           :with_votes,
           parent: freetown.edge)
  end
  let!(:other_motion) { create(:motion, parent: freetown.edge) }
  let!(:blog_post) do
    create(:blog_post,
           happening_attributes: {happened_at: Time.current},
           parent: motion.edge)
  end
  let!(:unpublished_blog_post) do
    create(:blog_post,
           happening_attributes: {happened_at: Time.current},
           edge_attributes: {argu_publication_attributes: {draft: true}},
           parent: motion.edge)
  end
  let!(:trashed_blog_post) do
    create(:blog_post,
           happening_attributes: {happened_at: Time.current},
           edge_attributes: {
             trashed_at: DateTime.current
           },
           parent: motion.edge)
  end
  let!(:trashed_unpublished_blog_post) do
    create(:blog_post,
           happening_attributes: {happened_at: Time.current},
           edge_attributes: {
             trashed_at: DateTime.current,
             argu_publication_attributes: {draft: true}
           },
           parent: motion.edge)
  end

  test 'fix counts for motion' do
    assert_counts(motion, blog_posts: 1, arguments_pro: 3, arguments_con: 2)
    assert_counts(motion.default_vote_event, votes_pro: 3, votes_con: 3, votes_neutral: 3)
    assert_counts(other_motion, blog_posts: 0, arguments_pro: 0, arguments_con: 0)
    assert_counts(other_motion.default_vote_event, votes_pro: 0, votes_con: 0, votes_neutral: 0)

    motion.edge.update(children_counts: {})
    motion.default_vote_event.edge.update(children_counts: {})
    other_motion.edge.update(children_counts: {})
    other_motion.default_vote_event.edge.update(children_counts: {})
    assert_counts(motion, blog_posts: 0, arguments_pro: 0, arguments_con: 0)
    assert_counts(motion.default_vote_event, votes_pro: 0, votes_con: 0, votes_neutral: 0)
    assert_counts(other_motion, blog_posts: 0, arguments_pro: 0, arguments_con: 0)
    assert_counts(other_motion.default_vote_event, votes_pro: 0, votes_con: 0, votes_neutral: 0)

    BlogPost.fix_counts
    assert_counts(motion, blog_posts: 1)
    Argument.fix_counts
    assert_counts(motion, arguments_pro: 2, arguments_con: 2)
    Vote.fix_counts
    assert_counts(motion.default_vote_event, votes_pro: 3, votes_con: 3, votes_neutral: 3)
  end

  test 'update count when trashing' do
    assert_counts(motion, blog_posts: 1)
    TrashService.new(blog_post, options: service_options).commit
    assert_counts(motion, blog_posts: 0)
  end

  test 'dont update count when trashing unpublished item' do
    assert_counts(motion, blog_posts: 1)
    TrashService.new(unpublished_blog_post, options: service_options).commit
    assert_counts(motion, blog_posts: 1)
  end

  test 'update count when untrashing' do
    assert_counts(motion, blog_posts: 1)
    UntrashService.new(trashed_blog_post, options: service_options).commit
    assert_counts(motion, blog_posts: 2)
  end

  test 'dont update count when untrashing unpublished item' do
    assert_counts(motion, blog_posts: 1)
    UntrashService.new(trashed_unpublished_blog_post, options: service_options).commit
    assert_counts(motion, blog_posts: 1)
  end

  test 'update count when publishing' do
    assert_counts(motion, blog_posts: 1)
    UpdateBlogPost.new(
      unpublished_blog_post,
      attributes: {edge_attributes: {argu_publication_attributes: {draft: false}}},
      options: service_options
    ).commit
    assert_difference('BlogPost.published.count', 1) do
      reset_publication(unpublished_blog_post.argu_publication)
    end
    assert_counts(motion, blog_posts: 2)
  end

  test 'dont update count when publishing trashed item' do
    assert_counts(motion, blog_posts: 1)
    UpdateBlogPost.new(
      trashed_unpublished_blog_post,
      attributes: {edge_attributes: {argu_publication_attributes: {draft: false}}},
      options: service_options
    ).commit
    assert_difference('BlogPost.published.count', 1) do
      reset_publication(trashed_unpublished_blog_post.argu_publication)
    end
    assert_counts(motion, blog_posts: 1)
  end

  test 'dont update count when publishing and trashing item' do
    assert_counts(motion, blog_posts: 1)
    UpdateBlogPost.new(
      unpublished_blog_post,
      attributes: {
        edge_attributes: {trashed_at: DateTime.current, argu_publication_attributes: {draft: false}}
      },
      options: service_options
    ).commit
    assert_difference('BlogPost.published.count', 1) do
      reset_publication(unpublished_blog_post.argu_publication)
    end
    assert_counts(motion, blog_posts: 1)
  end

  test 'update count when publishing and untrashing trashed item' do
    assert_counts(motion, blog_posts: 1)
    UpdateBlogPost.new(
      trashed_unpublished_blog_post,
      attributes: {
        edge_attributes: {trashed_at: nil, argu_publication_attributes: {draft: false}}
      },
      options: service_options
    ).commit
    assert_difference('BlogPost.published.count', 1) do
      reset_publication(trashed_unpublished_blog_post.argu_publication)
    end
    assert_counts(motion, blog_posts: 2)
  end

  private

  def assert_counts(record, counts)
    record.reload
    counts.each do |klass, count|
      assert_equal count, record.children_count(klass)
    end
  end

  def service_options
    user = create(:user)
    {
      creator: user.profile,
      publisher: user
    }
  end
end
