class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new #Guest users
    if user.has_role? :coder
        #The coder can do anything
        can [:manage, :vote], :all
        can [:add_admin, :remove_admin], User do |item| ##This is included in :manage according to the docs
          !item.has_role? :coder
        end
        #can [:add, :remove, :list], [:admin, :mod, :user]
    elsif user.has_role?(:admin) && !user.frozen?
      can [:panel, :search_username, :list], :admin
      can [:add, :remove, :list], [:mod, :user]
      can [:freeze, :unfreeze], User do |item|
        !item.has_any_role? :coder, :admin
      end
      can :trash, [Argument]
      #The admin can manage all the generic objects
      can [:manage, :revisions, :allrevisions, :vote],
          [Statement, 
           Argument,
           Comment,
           Profile,
           Card,
           Vote]
      can :manage, User do |u|
        user == u
      end
    elsif user.has_role?(:user) && !user.frozen?
        can :read, :all                                         #read by default, should be changed later
        can [:create, :placeComment, :report, :vote], [Statement, Argument, Comment, Card]
        can [:revisions, :allrevisions], [Statement, Argument]  #View revisions
        cannot :delete, [Statement, Argument]                   #No touching!
        cannot [:update, :delete], [PaperTrail::Version]                    #I said, no touching!

        ##Moderator rights
        can [:edit_mods, :create_mod, :destroy_mod], Statement do |item|
          user.has_role? :mod, item
        end
        can :trash, Argument do |item|
          user.has_role? :mod, item.statement
        end
        can :trash, Comment do |item|
          user.has_role? :mod, eval(item.commentable_type).find_by_id(item.commentable_id).statement
        end
        can [:edit, :update, :delete], Profile do |profile|     #Do whatever you want with your own profile
          user.profile == profile
        end

        ##Owned objects
        can [:show, :edit, :update, :search], User do |u|       #Same goes for your persona
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
        cannot [:manage],            #Closed beta, so bugger off!
               [Statement,
                Argument,
                Comment,
                Profile,
                Vote,
                Card,
                PaperTrail::Version]
        can :read, [Statement,
                    Argument,
                    Comment,
                    Profile,
                    Vote,
                    Card,
                    PaperTrail::Version]
    end
  end
end
