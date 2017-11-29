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
        country_code = attributes[:locale]&.split('-')&.second&.downcase || 'gb'
        unless Place.where("address->>'country_code' = ?", country_code).any?
          Place.create!(address: {country_code: country_code})
        end
        forum = create(
          :forum,
          *args,
          attributes
        )
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
              public_grant: 'participator'
            }.merge(attributes)
          )
        end
      end

      def define_cairo(name = 'cairo', attributes: {})
        let(name) do
          forum = create_forum(
            {
              shortname_attributes: {shortname: name}
            }.merge(attributes)
          )
          create(:grant,
                 edge: forum.edge,
                 group: create(:group, parent: forum.page.edge),
                 role: Grant.roles[:participator])
          forum
        end
      end

      def define_cologne(name = 'cologne', attributes: {})
        let(name) do
          forum = create_forum(
            :populated_forum,
            {
              shortname_attributes: {shortname: name}
            }.merge(attributes)
          )
          create(:grant,
                 edge: forum.edge,
                 group: create(:group, parent: forum.page.edge),
                 role: Grant.roles[:participator])
          forum
        end
      end

      def define_helsinki(name = 'helsinki', attributes: {})
        let(name) do
          forum = create_forum(
            {
              shortname_attributes: {shortname: name},
              discoverable: false
            }.merge(attributes)
          )
          create(:grant,
                 edge: forum.edge,
                 group: create(:group, parent: forum.page.edge),
                 role: Grant.roles[:participator])
          forum
        end
      end

      def define_holland(name = 'holland', attributes: {})
        let(name) do
          create_forum(
            :populated_forum,
            {
              shortname_attributes: {shortname: name},
              public_grant: 'participator'
            }.merge(attributes)
          )
        end
      end

      def define_spain(name = 'spain', attributes: {})
        let(name) do
          create_forum(
            :populated_forum,
            {
              shortname_attributes: {shortname: name},
              public_grant: 'spectator'
            }.merge(attributes)
          )
        end
      end

      def define_public_source
        define_page
        let!(:public_source) do
          create(:source,
                 parent: argu.edge,
                 iri_base: 'https://iri.test',
                 public_grant: 'participator',
                 shortname: 'public_source')
        end
      end
    end
  end
end
