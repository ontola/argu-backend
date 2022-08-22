# frozen_string_literal: true

module Argu
  module TestHelpers
    module TestResources
      module InstanceMethods
        def create_forum(*args) # rubocop:disable Metrics/MethodLength
          attributes = (args.pop if args.last.is_a?(Hash)) || {}
          page = attributes[:parent] || ActsAsTenant.current_tenant || create_page

          attributes = {
            url: attributes_for(:shortname)[:shortname],
            parent: page,
            options: {
              publisher: page.user
            }
          }.merge(attributes)
          ActsAsTenant.with_tenant(page) do
            create(
              :forum,
              *args,
              attributes
            )
          end
        end

        def create_page(**opts)
          ActsAsTenant.without_tenant { create(:page, opts) }
        end
      end

      module ClassMethods
        def define_page
          let!(:argu) do
            Page.find_via_shortname('argu')
          end
          let(:service_application) { create(:application, scopes: %i[guest user service]) }
          let(:frontend_application) { create(:application, scopes: %i[guest user staff]) }
        end

        def define_freetown(name = 'freetown', attributes: {}) # rubocop:disable Metrics/MethodLength
          define_page
          let!(name) do
            create_forum(
              :with_follower,
              {
                url: name,
                parent: argu,
                initial_public_grant: 'initiator'
              }.merge(attributes)
            )
          end
        end

        def define_cairo(name = 'cairo', attributes: {}) # rubocop:disable Metrics/MethodLength
          define_page

          let(name) do
            forum = create_forum({url: name, parent: argu}.merge(attributes))
            ActsAsTenant.with_tenant(forum.parent) do
              create(:grant,
                     edge: forum,
                     group: create(:group, parent: ActsAsTenant.current_tenant),
                     grant_set: GrantSet.initiator)
            end
            forum
          end
        end

        def define_helsinki(name = 'helsinki', attributes: {}) # rubocop:disable Metrics/MethodLength
          define_page

          let(name) do
            forum = create_forum(
              {
                url: name,
                discoverable: false,
                parent: argu
              }.merge(attributes)
            )
            ActsAsTenant.with_tenant(forum.parent) do
              create(:grant,
                     edge: forum,
                     group: create(:group, parent: forum.root),
                     grant_set: GrantSet.initiator)
            end
            forum
          end
        end

        def define_holland(name = 'holland', attributes: {}) # rubocop:disable Metrics/MethodLength
          define_page

          let(name) do
            create_forum(
              :populated_forum,
              {
                url: name,
                initial_public_grant: 'initiator',
                parent: argu
              }.merge(attributes)
            )
          end
        end
      end
    end
  end
end
