# frozen_string_literal: true

module Argu
  module TestResources
    module InstanceMethods
      def create_forum(*args) # rubocop:disable Metrics/AbcSize
        attributes = (args.pop if args.last.is_a?(Hash)) || {}
        page = attributes[:parent] || create(:page)
        attributes = {
          url: attributes_for(:shortname)[:shortname],
          parent: page,
          options: {
            publisher: page.user
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
        let!(:argu) do
          create(:page, profile_attributes: {name: 'Argu'})
        end
      end

      def define_freetown(name = 'freetown', attributes: {})
        define_page
        let!(name) do
          create_forum(
            :with_follower,
            {
              url: name,
              parent: argu,
              public_grant: 'initiator'
            }.merge(attributes)
          )
        end
      end

      def define_cairo(name = 'cairo', attributes: {})
        let(name) do
          forum = create_forum({url: name}.merge(attributes))
          create(:grant,
                 edge: forum,
                 group: create(:group, parent: forum.root),
                 grant_set: GrantSet.initiator)
          forum
        end
      end

      def define_cologne(name = 'cologne', attributes: {})
        let(name) do
          forum = create_forum(:populated_forum, {url: name}.merge(attributes))
          create(:grant,
                 edge: forum,
                 group: create(:group, parent: forum.root),
                 grant_set: GrantSet.initiator)
          forum
        end
      end

      def define_helsinki(name = 'helsinki', attributes: {})
        let(name) do
          forum = create_forum(
            {
              url: name,
              discoverable: false
            }.merge(attributes)
          )
          create(:grant,
                 edge: forum,
                 group: create(:group, parent: forum.root),
                 grant_set: GrantSet.initiator)
          forum
        end
      end

      def define_holland(name = 'holland', attributes: {})
        let(name) do
          create_forum(
            :populated_forum,
            {
              url: name,
              public_grant: 'initiator'
            }.merge(attributes)
          )
        end
      end

      def define_spain(name = 'spain', attributes: {})
        let(name) do
          create_forum(
            :populated_forum,
            {
              url: name,
              public_grant: 'spectator'
            }.merge(attributes)
          )
        end
      end
    end
  end
end
