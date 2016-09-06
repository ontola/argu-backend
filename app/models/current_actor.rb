class CurrentActor < ActiveModelSerializers::Model
  attr_accessor :user_state, :discover, :memberships, :actor,
                :current_forum, :groups, :managed_pages
end
