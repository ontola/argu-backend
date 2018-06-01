# frozen_string_literal: true

class NoRootPolicy < RestrictivePolicy
  def create_child?(_raw_klass)
    false
  end

  def index_children?(_raw_klass)
    false
  end

  def has_expired_ancestors?
    false
  end
end
