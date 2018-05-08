# frozen_string_literal: true

require 'test_helper'

module RedisResource
  class RelationTest < ActiveSupport::TestCase
    define_freetown
    let(:user) { create(:user) }
    let(:guest_user) { GuestUser.new(id: 'my_id') }
    let(:other_guest_user) { GuestUser.new(id: 'other_id') }
    let(:unconfirmed) { create(:user, :unconfirmed) }
    let(:relation) { RedisResource::Relation.where(publisher: guest_user) }
    let(:edge_relation) { RedisResource::EdgeRelation.where(publisher: guest_user) }
    let(:motion) { create(:motion, parent: freetown.edge) }

    test 'count' do
      init_redis_votes(count: 2)
      init_redis_votes(user: other_guest_user, count: 1)
      assert_equal 2, relation.count
      relation.where(path: Motion.first.default_vote_event.edge.path)
      assert_equal 1, relation.count
      relation.where(parent: Motion.first.default_vote_event.edge)
      assert_equal 1, relation.count
      relation.where(path: freetown.edge.path).count
      assert_equal 0, relation.count
      relation.where(path: "#{freetown.edge.path}.*").count
      assert_equal 2, relation.count
    end

    test 'where' do
      init_redis_votes(count: 5)
      init_redis_votes(user: other_guest_user, count: 1)
      first_result = relation.where(path: Motion.first.default_vote_event.edge.path).to_a.first
      assert first_result.is_a?(RedisResource::Resource)
      assert first_result.resource.is_a?(Vote)
    end

    test 'where edge_relation' do
      init_redis_votes(count: 5)
      init_redis_votes(user: other_guest_user, count: 1)
      first_result = edge_relation.where(path: Motion.first.default_vote_event.edge.path).to_a.first
      assert first_result.is_a?(Edge)
      assert first_result.owner.is_a?(Vote)
    end

    test 'find first' do
      init_redis_votes(count: 5)
      init_redis_votes(user: other_guest_user, count: 1)
      assert relation.first.is_a?(RedisResource::Resource)
      assert relation.first.resource.is_a?(Vote)
    end

    test 'find first edge_relation' do
      init_redis_votes(count: 5)
      init_redis_votes(user: other_guest_user, count: 1)
      assert edge_relation.first.is_a?(Edge)
      assert edge_relation.first.owner.is_a?(Vote)
    end

    test 'persist' do
      init_redis_votes(count: 1)
      init_redis_votes(user: other_guest_user, count: 1)
      assert_equal 1, relation.count

      # persist votes
      assert_differences([['Vote.count', 1], ['Edge.where(confirmed: true).count', 0]]) do
        relation.persist(unconfirmed)
      end
    end

    private

    def create_vote(user, attrs = {})
      Vote.create(
        {
          creator: user.profile,
          publisher: user,
          for: :pro,
          edge: Edge.new(parent: motion.default_vote_event.edge, user: user),
          root_id: motion.root_id
        }.merge(attrs)
      )
    end

    def init_redis_votes(user: guest_user, count: 1)
      count.times do
        create(
          :vote,
          parent: create(:motion, parent: freetown.edge).default_vote_event.edge,
          creator: user.profile,
          publisher: user
        )
      end
    end
  end
end
