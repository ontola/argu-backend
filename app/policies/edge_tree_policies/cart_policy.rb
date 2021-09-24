# frozen_string_literal: true

class CartPolicy < EdgeTreePolicy
  delegate :show?, to: :edgeable_policy

  def index_children?(raw_klass, **opts)
    return super unless raw_klass == CartDetail

    true
  end
end
