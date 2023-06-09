# frozen_string_literal: true

require 'test_helper'

class CounterCacheTest < ActiveSupport::TestCase
  define_freetown
  let!(:motion) do
    create(:motion,
           :with_arguments,
           :with_votes,
           parent: freetown)
  end
  let!(:other_motion) { create(:motion, parent: freetown) }
  let!(:blog_post) do
    create(:blog_post,
           parent: motion)
  end
  let!(:unpublished_blog_post) do
    create(:blog_post,
           argu_publication_attributes: {draft: true},
           parent: motion)
  end
  let!(:trashed_blog_post) do
    create(:blog_post,
           trashed_at: Time.current,
           parent: motion)
  end
  let!(:trashed_unpublished_blog_post) do
    create(:blog_post,
           trashed_at: Time.current,
           argu_publication_attributes: {draft: true},
           parent: motion)
  end
  let(:unconfirmed) { create(:unconfirmed_user) }
  let!(:unconfirmed_vote) do
    create(:vote, parent: motion.default_vote_event, creator: unconfirmed.profile, publisher: unconfirmed)
  end

  before do
    ActsAsTenant.current_tenant = argu
  end

  test 'fix counts for motion' do
    assert_counts(motion, blog_posts: 1, pro_arguments: 2, con_arguments: 2)
    assert_counts(motion.default_vote_event, votes_pro: 2, votes_con: 2, votes_neutral: 2)
    assert_counts(other_motion, blog_posts: 0, pro_arguments: 0, con_arguments: 0)
    assert_counts(other_motion.default_vote_event, votes_pro: 0, votes_con: 0, votes_neutral: 0)

    motion.update(children_counts: {blog_posts: 0, pro_arguments: 0, con_arguments: 0})
    motion.default_vote_event.update(children_counts: {votes_pro: 0, votes_con: 0, votes_neutral: 0})
    other_motion.update(children_counts: {blog_posts: 0, pro_arguments: 0, con_arguments: 0})
    other_motion.default_vote_event.update(children_counts: {votes_pro: 0, votes_con: 0, votes_neutral: 0})
    assert_counts(motion, blog_posts: 0, pro_arguments: 0, con_arguments: 0)
    assert_counts(motion.default_vote_event, votes_pro: 0, votes_con: 0, votes_neutral: 0)
    assert_counts(other_motion, blog_posts: 0, pro_arguments: 0, con_arguments: 0)
    assert_counts(other_motion.default_vote_event, votes_pro: 0, votes_con: 0, votes_neutral: 0)

    BlogPost.fix_counts
    assert_counts(motion, blog_posts: 1)
    ProArgument.fix_counts
    ConArgument.fix_counts
    assert_counts(motion, pro_arguments: 2, con_arguments: 2)
    Vote.fix_counts
    assert_counts(motion.default_vote_event, votes_pro: 2, votes_con: 2, votes_neutral: 2)
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
    UpdateEdge.new(
      unpublished_blog_post,
      attributes: {argu_publication_attributes: {draft: false}},
      options: service_options
    ).commit
    assert_difference('BlogPost.published.count', 1) do
      reset_publication(unpublished_blog_post.argu_publication)
    end
    assert_counts(motion, blog_posts: 2)
  end

  test 'dont update count when publishing trashed item' do
    assert_counts(motion, blog_posts: 1)
    UpdateEdge.new(
      trashed_unpublished_blog_post,
      attributes: {argu_publication_attributes: {draft: false}},
      options: service_options
    ).commit
    assert_difference('BlogPost.published.count', 1) do
      reset_publication(trashed_unpublished_blog_post.argu_publication)
    end
    assert_counts(motion, blog_posts: 1)
  end

  test 'dont update count when publishing and trashing item' do
    assert_counts(motion, blog_posts: 1)
    UpdateEdge.new(
      unpublished_blog_post,
      attributes: {
        trashed_at: Time.current, argu_publication_attributes: {draft: false}
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
    UpdateEdge.new(
      trashed_unpublished_blog_post,
      attributes: {
        trashed_at: nil, argu_publication_attributes: {draft: false}
      },
      options: service_options
    ).commit
    assert_difference('BlogPost.published.count', 1) do
      reset_publication(trashed_unpublished_blog_post.argu_publication)
    end
    assert_counts(motion, blog_posts: 2)
  end

  test 'update count when changing vote' do
    assert_counts(motion.default_vote_event, votes_pro: 2, votes_con: 2, votes_neutral: 2)
    yes_term = motion.default_vote_event.option_record!(NS.argu[:yes])
    voter = motion.default_vote_event.votes.joins(:properties).find_by(
      properties: {
        predicate: NS.schema.option.to_s, linked_edge: yes_term
      }
    )
              .publisher
    CreateVote.new(
      motion.default_vote_event,
      attributes: {option: NS.argu[:no]},
      options: service_options(publisher: voter)
    ).commit
    assert_counts(motion.default_vote_event, votes_pro: 1, votes_con: 3, votes_neutral: 2)
    Vote.fix_counts
    assert_counts(motion.default_vote_event, votes_pro: 1, votes_con: 3, votes_neutral: 2)
  end

  test 'dont update count when posting unconfirmed vote' do
    assert_counts(motion.default_vote_event, votes_pro: 2, votes_con: 2, votes_neutral: 2)
    CreateVote.new(
      motion.default_vote_event,
      attributes: {option: NS.argu[:no]},
      options: service_options(publisher: unconfirmed)
    ).commit
    assert_counts(motion.default_vote_event, votes_pro: 2, votes_con: 2, votes_neutral: 2)
    Vote.fix_counts
    assert_counts(motion.default_vote_event, votes_pro: 2, votes_con: 2, votes_neutral: 2)
  end

  private

  def assert_counts(record, counts)
    record.reload
    counts.each do |key, count|
      counter_key = key_for_counter(record, key)
      assert_equal(
        count,
        record.children_count(counter_key),
        "Wrong #{counter_key}(#{key}) count: #{record.children_counts}"
      )
    end
  end

  def key_for_counter(record, key)
    case key
    when :votes_pro
      record.option_record(NS.argu[:yes]).uuid
    when :votes_con
      record.option_record(NS.argu[:no]).uuid
    when :votes_neutral
      record.option_record(NS.argu[:other]).uuid
    else
      key
    end
  end
end
