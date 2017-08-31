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
    let(:vote) { create(:vote, publisher: unconfirmed, parent: motion.default_vote_event.edge) }

    test 'find by key string' do
      redis_resource = RedisResource::Resource
                         .find("temporary.user.#{unconfirmed.id}.vote.#{vote.edge.id}.#{vote.edge.parent.path}")
      assert redis_resource.is_a?(RedisResource::Resource)
      assert redis_resource.resource == vote
      assert_not redis_resource.resource.persisted?
    end

    test 'find by key object' do
      key = RedisResource::Key.new(
        user: unconfirmed,
        owner_type: 'vote',
        edge_id: vote.edge.id,
        path: motion.default_vote_event.edge.path,
        parent_id: motion.default_vote_event.edge.id
      )
      redis_resource = RedisResource::Resource.find(key)
      assert redis_resource.is_a?(RedisResource::Resource)
      assert redis_resource.resource == vote
      assert_not redis_resource.resource.persisted?
    end

    test 'save' do
      assert_differences([['Vote.count', 1], ['Argu::Redis.keys("temporary*").count', 0]]) do
        create_vote(user)
      end
      assert_differences([['Vote.count', 0], ['Argu::Redis.keys("temporary*").count', 1]]) do
        create_vote(unconfirmed)
      end
      assert_differences([['Vote.count', 0], ['Argu::Redis.keys("temporary*").count', 1]]) do
        create_vote(guest_user)
      end
    end

    test 'save when record already exists in postgres' do
      vote = create_vote(user, for: :con)
      assert vote.con?
      user.primary_email_record.update(confirmed_at: nil)
      user.remove_instance_variable('@confirmed')
      assert_differences([['Vote.count', 0], ['Argu::Redis.keys("temporary*").count', 1]]) do
        create_vote(user)
      end
      assert RedisResource::Relation.where(publisher: user).first.resource.pro?
    end

    test 'destroy' do
      vote = create_vote(user)
      assert_differences([['Vote.count', -1], ['Argu::Redis.keys("temporary*").count', 0]]) do
        vote.destroy
      end
      unconfirmed_vote = create_vote(unconfirmed)
      assert_differences([['Vote.count', 0], ['Argu::Redis.keys("temporary*").count', -1]]) do
        unconfirmed_vote.destroy
      end
    end

    test 'destroy when record already exists in postgres' do
      vote = create_vote(user, for: :con)
      key = RedisResource::Key.new(
        path: vote.parent_edge.path,
        owner_type: 'Vote',
        user: vote.publisher,
        edge_id: vote.edge.id
      ).key
      Argu::Redis.set(key, vote.attributes.merge(persisted: true).to_json)
      user.primary_email_record.update(confirmed_at: nil)
      user.remove_instance_variable('@confirmed')
      assert_differences([['Vote.count', -1], ['Argu::Redis.keys("temporary*").count', -1]]) do
        vote.destroy
      end
    end

    test 'destroy parent' do
      unconfirmed_vote = create_vote(unconfirmed)
      assert_differences([['Motion.count', -1], ['Vote.count', 0], ['Argu::Redis.keys("temporary*").count', -1]]) do
        unconfirmed_vote.parent_model.parent_model.destroy
      end
    end

    test 'destroy parent when record already exists in postgres' do
      vote = create_vote(user, for: :con)
      key = RedisResource::Key.new(
        path: vote.parent_edge.path,
        owner_type: 'Vote',
        user: vote.publisher,
        edge_id: vote.edge.id
      ).key
      Argu::Redis.set(key, vote.attributes.merge(persisted: true).to_json)
      user.primary_email_record.update(confirmed_at: nil)
      user.remove_instance_variable('@confirmed')
      assert_differences([['Motion.count', -1], ['Vote.count', -1], ['Argu::Redis.keys("temporary*").count', -1]]) do
        vote.parent_model.parent_model.destroy
      end
    end

    test 'persist' do
      redis_resource = RedisResource::Resource
                         .find("temporary.user.#{unconfirmed.id}.vote.#{vote.edge.id}.#{vote.edge.parent.path}")
      assert_not vote.persisted?
      assert_differences([['Vote.count', 1], ['Argu::Redis.keys("temporary*").count', -1]]) do
        redis_resource.persist(user)
      end
      assert vote.reload.persisted?
    end

    test 'persist when already present in postgres' do
      vote
      confirmed_vote.update(publisher_id: unconfirmed.id, creator_id: unconfirmed.profile.id)
      confirmed_vote.edge.update(user_id: unconfirmed.id)
      redis_resource = RedisResource::Resource
                         .find("temporary.user.#{unconfirmed.id}.vote.#{vote.edge.id}.#{vote.edge.parent.path}")
      unconfirmed.primary_email_record.update(confirmed_at: DateTime.current)
      redis_resource.persist(unconfirmed)
    end

    private

    def create_vote(user, attrs = {})
      Vote.create(
        {
          creator: user.profile,
          publisher: user,
          for: :pro,
          edge: Edge.new(parent: motion.default_vote_event.edge, user: user)
        }.merge(attrs)
      )
    end
  end
end
