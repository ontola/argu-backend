class TagPolicy < ForumPolicy
  class Scope < Scope
    def resolve
      scope
    end

  end
end