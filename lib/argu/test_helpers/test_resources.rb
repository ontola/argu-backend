# frozen_string_literal: true
module Argu
  module TestResources
    module InstanceMethods
      def create_forum(*args)
        attributes = (args.pop if args.last.is_a?(Hash)) || {}
        page = attributes.delete(:page) || create(:page)
        attributes = {
          shortname_attributes: attributes_for(:shortname),
          parent: page.edge,
          page: page,
          options: {
            publisher: page.owner.profileable
          }
        }.merge(attributes)
        forum = create(
          :forum,
          *args,
          attributes
        )
        forum.reset_public_grant
        forum
      end
    end

    module ClassMethods
      def define_page
        let!(:argu) { create(:page) }
      end

      def define_freetown(name = 'freetown', attributes: {})
        define_page
        let!(name) do
          create_forum(
            :with_follower,
            {
              shortname_attributes: {shortname: name},
              page: argu,
              parent: argu.edge,
              visibility: Forum.visibilities[:open]
            }.merge(attributes)
          )
        end
      end

      def define_cairo(name = 'cairo', attributes: {})
        let!(name) do
          forum = create_forum(
            {
              shortname_attributes: {shortname: name},
              visibility: Forum.visibilities[:closed]
            }.merge(attributes)
          )
          create(:grant,
                 edge: forum.edge,
                 group: create(:group, parent: forum.page.edge),
                 role: Grant.roles[:member])
          forum
        end
      end

      def define_cologne(name = 'cologne', attributes: {})
        let!(name) do
          forum = create_forum(
            :populated_forum,
            {
              shortname_attributes: {shortname: name},
              visibility: Forum.visibilities[:closed]
            }.merge(attributes)
          )
          create(:grant,
                 edge: forum.edge,
                 group: create(:group, parent: forum.page.edge),
                 role: Grant.roles[:member])
          forum
        end
      end

      def define_helsinki(name = 'helsinki', attributes: {})
        let!(name) do
          forum = create_forum(
            {
              shortname_attributes: {shortname: name},
              visibility: Forum.visibilities[:hidden],
              visible_with_a_link: true
            }.merge(attributes)
          )
          create(:grant,
                 edge: forum.edge,
                 group: create(:group, parent: forum.page.edge),
                 role: Grant.roles[:member])
          create :access_token, item: forum
          forum
        end
      end

      def define_holland(name = 'holland', attributes: {})
        let!(name) do
          create_forum(
            :populated_forum,
            {
              shortname_attributes: {shortname: name},
              visibility: Forum.visibilities[:open]
            }.merge(attributes)
          )
        end
      end

      def define_venice(name = 'venice', attributes: {})
        let!(name) do
          forum = create_forum(
            {
              visible_with_a_link: true
            }.merge(attributes)
          )
          create(:grant,
                 edge: forum.edge,
                 group: create(:group, parent: forum.page.edge),
                 role: Grant.roles[:member])
          forum
        end
      end
    end
  end
end
