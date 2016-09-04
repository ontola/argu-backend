class CurrentActor < ActiveModelSerializers::Model
  attr_accessor :user_state, :discover, :memberships, :profile,
                :current_forum, :groups, :managed_pages
end
