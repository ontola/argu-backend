class CurrentActorSerializer < BaseSerializer
  attributes :user_state, :discover, :memberships
  has_one :actor
end
