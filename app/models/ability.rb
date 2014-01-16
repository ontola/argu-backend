class   Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new #Guest users
    if user.has_role? :coder
        #The coder can do anything
        can :manage, :all
        can [:panel, :list, :search_username, :add, :remove], :admin
        can [:add, :remove, :list], [:admin, :mod, :user]
    elsif user.has_role? :admin
      can [:panel, :search_username], :admin
      can [:add, :remove, :list], [:mod, :user]
      can :list, :admin
      cannot [:admin, :mod, :user], User do |item|
        item.has_any_role? :coder, :admin
      end
      can :trash, [Argument]
      #The admin can manage all the generic objects
      can [:manage, :revisions, :allrevisions],
          [Statement, 
           Argument,
           Comment,
           Profile,
           Vote]
      can :manage, User do |u|
        user == u
      end
    elsif user.has_role? :mod
      can :list, :mod
      can :trash, Argument do |item|
        user.is_mod_of? item.statement
      end
      can :trash, Comment do |item|
        user.is_mod_of? eval(item.commentable_type).find_by_id(item.commentable_id).statement
      end
      cannot [:mod, :user], User do |item|
        item.has_any_role? :coder, :admin, :mod
      end
      can [:edit_mod, :create_mod, :destroy_mod], Statement do |item|
        user.is_mod_of? item
      end
    elsif user.has_role? :user
        cannot :manage, User do |u|
          user != u
        end
        can :read, :all                                         #read by default, should be changed later
        can :create, [Statement, Argument, Comment]
        can :update, [Statement, Argument] do |item|
          item.is_moderator?(user)
        end
        can [:revisions, :allrevisions], [Statement, Argument]  #View revisions
        can :placeComment, [Statement, Argument, Comment]
        cannot :delete, [Statement, Argument ]                  #No touching!
        cannot [:update, :delete], [Version]                    #I said, no touching!
        can [:edit, :update, :delete], Profile do |profile|     #Do whatever you want with your own profile
            user.profile == profile
        end
        can [:show, :update, :search], User do |u|                       #Same goes for your persona
          user == u
        end
        can :destroyComment, Comment do |comment|
          (comment.user == user)
        end
        can [:edit, :update], Comment do |comment|              #And your comments
          comment.user == user
        end
        can [:manage], Vote do |vote|                           #Freedom in democracy
          user.id == vote.voter_id
        end
    else
        cannot [:manage, :revisions, :allrevisions],            #Closed beta, so bugger off!
               [Statement,
                Argument,
                Comment,
                Profile,
                Vote,
                Version]
    end
  end
end
