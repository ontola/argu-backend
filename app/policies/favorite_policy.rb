# frozen_string_literal: true
class FavoritePolicy < EdgeTreePolicy
  private

  alias create_roles default_create_roles

  def destroy_roles
    [is_creator?]
  end

  def is_creator?
    creator if record.user == user
  end
end
