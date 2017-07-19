# frozen_string_literal: true
class LinkedRecordPolicy < EdgeTreePolicy
  alias create_roles default_create_roles
  alias trash_roles default_trash_roles
  alias untrash_roles default_untrash_roles
  alias update_roles default_update_roles
  alias show_roles default_show_roles
  alias show_unpublished_roles default_show_unpublished_roles
end
