# frozen_string_literal: true
class ForumSerializer < BaseSerializer
  attributes :display_name, :shortname

  def id
    object.shortname.shortname
  end
end
