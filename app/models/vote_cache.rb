# frozen_string_literal: true

class VoteCache
  def initialize(profile)
    @profile = profile
    @cached = {}
  end

  def by_parent(parent)
    cache!(parent).detect { |vote| vote.parent_id == parent.id } if parent.persisted?
  end

  def cache!(parent)
    if @profile.profileable.guest?
      @cached[parent.root_id] ||= preload_from_redis(parent)
    else
      @cached[parent.root_id] ||= {}
      parent_id = (parent.path.split('.').reverse.map(&:to_i) & @cached[parent.root_id].keys).first
      if parent_id
        @cached[parent.root_id][parent_id]
      else
        @cached[parent.root_id][parent.id] ||= preload_from_postgres(parent)
      end
    end
  end

  private

  def preload_from_postgres(parent)
    Vote
      .where(creator: @profile, primary: true, root_id: parent.root_id)
      .where('edges.path <@ ?', parent.path)
      .includes(Vote.includes_for_serializer)
      .to_a
  end

  def preload_from_redis(parent)
    RedisResource::EdgeRelation.where(owner_type: 'Vote', root_id: parent.root_id, creator: @profile)
  end
end
