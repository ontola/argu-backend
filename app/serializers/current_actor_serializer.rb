# frozen_string_literal: true
class CurrentActorSerializer < BaseSerializer
  attributes %i(actor_type finished_intro display_name shortname)
end
