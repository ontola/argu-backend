# frozen_string_literal: true

require 'test_helper'

module RedisResource
  class ResourceTest < ActiveSupport::TestCase
    define_freetown
    let(:guest_user) { GuestUser.new(id: 'my_id') }
    let(:unconfirmed) { create(:user, :unconfirmed) }
    let(:user) { create(:user) }
    let(:motion) { create(:motion, parent: freetown.edge) }
    let(:confirmed_vote) { create(:vote, publisher: user, parent: motion.default_vote_event.edge) }
    let(:vote) { create(:vote, publisher: user, parent: motion.default_vote_event.edge) }
    let(:guest_vote) { create(:vote, publisher: guest_user, parent: motion.default_vote_event.edge) }

    test 'find by key string' do
      redis_resource =
        RedisResource::Resource
          .find("temporary.guest_user.#{guest_user.id}.vote.#{guest_vote.edge.id}.#{guest_vote.edge.parent.path}")
      assert redis_resource.is_a?(RedisResource::Resource)
      assert redis_resource.resource == guest_vote
      assert_not redis_resource.resource.persisted?
    end

    test 'find by key object' do
      key = RedisResource::Key.new(
        user: guest_user,
        owner_type: 'vote',
        edge_id: guest_vote.edge.id,
        path: motion.default_vote_event.edge.path,
        parent_id: motion.default_vote_event.edge.id
      )
      redis_resource = RedisResource::Resource.find(key)
      assert redis_resource.is_a?(RedisResource::Resource)
      assert redis_resource.resource == guest_vote
      assert_not redis_resource.resource.persisted?
    end

    test 'save' do
      assert_differences([['Vote.count', 1], ['Argu::Redis.keys("temporary*").count', 0]]) do
        create_vote(user)
      end
      assert_differences([['Vote.count', 1], ['Argu::Redis.keys("temporary*").count', 0]]) do
        create_vote(unconfirmed)
      end
      assert_differences([['Vote.count', 0], ['Argu::Redis.keys("temporary*").count', 1]]) do
        create_vote(guest_user)
      end
    end

    test 'destroy' do
      guest_vote
      assert_differences([['Vote.count', 0], ['Argu::Redis.keys("temporary*").count', -1]]) do
        guest_vote.destroy
      end
      vote = create_vote(user)
      assert_differences([['Vote.count', -1], ['Argu::Redis.keys("temporary*").count', 0]]) do
        vote.destroy
      end
      unconfirmed_vote = create_vote(unconfirmed)
      assert_differences([['Vote.count', -1], ['Argu::Redis.keys("temporary*").count', 0]]) do
        unconfirmed_vote.destroy
      end
    end

    test 'destroy parent' do
      guest_vote
      assert_differences([['Motion.count', -1], ['Vote.count', 0], ['Argu::Redis.keys("temporary*").count', -1]]) do
        guest_vote.parent_model.parent_model.destroy
      end
    end

    test 'persist' do
      redis_resource =
        RedisResource::Resource
          .find("temporary.guest_user.#{guest_user.id}.vote.#{guest_vote.edge.id}.#{guest_vote.edge.parent.path}")
      assert_differences([['Vote.count', 1], ['Argu::Redis.keys("temporary*").count', -1]]) do
        redis_resource.persist(user)
      end
    end

    test 'persist when already present in postgres' do
      vote
      redis_resource =
        RedisResource::Resource
          .find("temporary.guest_user.#{guest_user.id}.vote.#{guest_vote.edge.id}.#{guest_vote.edge.parent.path}")
      assert_differences([['Vote.count', 0], ['Argu::Redis.keys("temporary*").count', -1]]) do
        redis_resource.persist(user)
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
  end
end
