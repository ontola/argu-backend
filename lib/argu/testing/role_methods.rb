module Argu
  module Testing
    module RoleMethods
      def change_actor(actor)
        a = actor.respond_to?(:profile) ? actor.profile : actor
        @controller.instance_variable_set(:@_current_actor, a)
      end

      def create_manager(forum, user = nil, *args)
        user ||= create(:user, *args)
        create(:managership, forum: forum, profile: user.profile)
        user
      end

      def create_member(forum, user = nil, *args)
        user ||= create(:user, *args)
        create(:membership, forum: forum, profile: user.profile)
        user
      end

      def create_group_member(group, user_or_page = nil, *args)
        user_or_page ||= create_member(group.forum)
        create(:group_membership,
               group: group,
               member: user_or_page.profile)
        user_or_page
      end

      def create_moderator(record, user = nil, *args)
        user ||= create(:user)
        forum = record.is_a?(Forum) ? record : record.forum
        create(:stepup, forum: forum, record: record, moderator: create_member(forum, user))
        user
      end

      # Makes the given `User` a manager of the `Page` of the `Forum`
      # Creates one if not given
      # @note overwrites the current owner in the `Page`
      def create_owner(forum, user = nil, *args)
        user ||= create(:user)
        forum.page.owner = user.profile
        assert_equal true, forum.page.save, "Couldn't create owner"
        user
      end

      def create_forum_owner_pair(forum_opts = {}, manager_opts = {})
        user = create(:user, manager_opts)
        forum = create((forum_opts[:type] || :forum),
                       page: create(:page,
                                    owner: user.profile))
        [forum, user]
      end
    end
  end
end
