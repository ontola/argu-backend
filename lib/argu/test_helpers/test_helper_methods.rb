# frozen_string_literal: true

require 'argu/test_helpers/test_resources'
require 'argu/test_helpers/automated_tests/asserts'

# Shared helper method across TestUnit and RSpec
module Argu
  module TestHelpers
    module TestHelperMethods
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.extend(ClassMethods)
      end

      module InstanceMethods
        include TestResources::InstanceMethods
        SERVICE_MODELS = %i[argument blog_post comment forum group_membership motion source
                            phase banner group project question vote decision grant vote_event vote_match].freeze

        def cascaded_forum(key, opts)
          key && opts.dig(key, :forum) || opts.dig(:forum) || try(:freetown)
        end

        def create(model_type, *args)
          attributes = HashWithIndifferentAccess.new
          attributes.merge!(args.pop) if args.last.is_a?(Hash)
          if SERVICE_MODELS.include?(model_type)
            create_with_service(model_type, args, attributes)
          else
            FactoryGirl.create(model_type, *args, attributes)
          end
        end

        def create_with_service(model_type, args, attributes)
          traits_with_args = attributes.delete(:traits_with_args) || {}
          klass = model_type.to_s.classify.constantize

          options = attributes.delete(:options) || {}
          options[:publisher] ||= attributes.delete(:publisher)
          options[:creator] ||= attributes.delete(:creator)

          attributes.merge!(attributes_for(model_type, attributes))
          if model_type.to_s.classify.constantize.is_publishable?
            attributes[:edge_attributes] ||= {}
          end

          if klass.nested_attributes_options?
            klass.nested_attributes_options.keys.each do |association|
              if attributes.include? association
                attributes["#{association}_attributes"] = attributes.delete(association).attributes
              end
            end
          end

          resource = create_resource(
            klass,
            attributes,
            options
          )

          args.each do |trait|
            TraitListener.new(resource).public_send(trait)
          end
          traits_with_args.each do |trait|
            TraitListener.new(resource).public_send(trait[0], trait[1])
          end

          if resource.respond_to?(:publications)
            reset_publication(resource.publications.last)
            resource.reload
          end

          resource
        end

        def create_manager(record, user = nil)
          user ||= create(:user)
          page = record.is_a?(Page) ? record : record.page
          group = create(:group, parent: page.edge)
          create(:group_membership,
                 parent: group,
                 shortname: user.url)
          create(:grant, edge: record.edge, group: group, role: Grant.roles['manager'])
          user
        end

        def create_member(record, user = nil)
          user ||= create(:user)
          page = record.is_a?(Page) ? record : record.page
          group = create(:group, parent: page.edge)
          create(:group_membership,
                 parent: group,
                 shortname: user.url)
          create(:grant, edge: record.edge, group: group, role: Grant.roles['member'])
          user
        end

        def create_super_admin(record, user = nil)
          user ||= create(:user)
          page = record.is_a?(Page) ? record : record.page
          create(:group_membership, parent: page.edge.groups.custom.first, member: user.profile)
          user
        end

        def create_forum_owner_pair(forum_opts = {}, manager_opts = {})
          user = create(:user, manager_opts)
          forum = create((forum_opts[:type] || :forum),
                         page: create(:page,
                                      owner: user.profile))
          [forum, user]
        end

        def create_follower(item, user = nil)
          user ||= create(:user)
          create(:follow, followable: item.edge, follower: user)
          user
        end

        def create_resource(klass, attributes = {}, options = {})
          options[:publisher] = create(:user, confirmed_at: DateTime.current) if options[:publisher].nil?
          options[:creator] = options[:publisher].profile if options[:creator].nil?

          parent_edge = attributes.delete(:parent)

          service_class = "Create#{klass}".safe_constantize || CreateService
          service = service_class.new(parent_edge, attributes: attributes, options: options)
          service.commit
          raise service.resource.errors.full_messages.first unless service.resource.valid?
          service.resource.store_in_redis? ? service.resource : service.resource.reload
        end

        def destroy_resource(resource, user = nil, profile = nil)
          user ||= create(:user)
          profile ||= user.profile
          options = {}
          options[:publisher] = user
          options[:creator] = profile
          service_class = "Destroy#{resource.class}".safe_constantize || DestroyService
          service = service_class.new(resource, attributes: {}, options: options)
          service.subscribe(ActivityListener.new(creator: profile,
                                                 publisher: user))
          service.commit
          nil
        end

        def open_file(filename)
          File.open("test/files/#{filename}")
        end

        def reset_publication(publication)
          return if publication.nil?
          publication.update(published_at: publication.published_at - 10.seconds) if publication.published_at.present?
          if publication.published_at.present? && publication.published_at <= DateTime.current
            Sidekiq::Testing.inline! do
              publication.send(:reset)
            end
          else
            publication.send(:reset)
          end
        end

        def stats_opt(category, action)
          {category: category, action: action}
        end

        def sign_in(resource = create(:user))
          id, role =
            case resource
            when :service
              [0, 'service']
            when :guest
              [SecureRandom.hex, 'guest']
            else
              [resource.id, 'user']
            end
          t = Doorkeeper::AccessToken.find_or_create_for(
            Doorkeeper::Application.argu,
            id,
            role,
            10.minutes,
            false
          )
          @request.headers['Authorization'] = "Bearer #{t.token}"
        end

        def trash_resource(resource, user = nil, profile = nil)
          user ||= create(:user)
          profile ||= user.profile
          options = {}
          options[:publisher] = user
          options[:creator] = profile
          service_class = "Trash#{resource.class}".safe_constantize || TrashService
          service = service_class.new(resource, attributes: {}, options: options)
          service.subscribe(ActivityListener.new(creator: profile,
                                                 publisher: user))
          service.commit
          resource.reload
        end

        def update_resource(resource, attributes = {}, user = nil, profile = nil)
          user ||= create(:user)
          profile ||= user.profile
          options = {}
          options[:publisher] = user
          options[:creator] = profile
          service_class = "Update#{resource.class}".safe_constantize || UpdateService
          service = service_class.new(resource, attributes: attributes, options: options)
          service.subscribe(ActivityListener.new(creator: profile,
                                                 publisher: user))
          service.commit
          resource.reload
        end
      end

      module ClassMethods
        include TestResources::ClassMethods
        include Argu::TestHelpers::AutomatedTests::Asserts

        def define_automated_tests_objects
          define_common_objects(:freetown, :spectator, :user, :member, :non_member, :creator,
                                :manager, :owner, :staff, :page)
        end

        def define_common_objects(*let)
          define_freetown
          let(:spectator) { user } if mdig?(:spectator, let)
          let(:user) { create(:user) } if mdig?(:user, let)
          let(:member) { create_member(freetown) } if mdig?(:member, let)
          let(:non_member) { user } if mdig?(:non_member, let)
          let(:creator) { create_member(freetown) } if mdig?(:creator, let)
          let(:manager) { create_manager(freetown) } if mdig?(:manager, let)
          let(:super_admin) { create_super_admin(freetown) } if mdig?(:owner, let)
          let(:staff) { create(:user, :staff) } if mdig?(:staff, let)
          let(:page) { argu } if mdig?(:page, let)
        end

        # @param [Symbol] key The key to search for.
        # @param [Array] arr Array of options to search in.
        # @return [Boolean] Whether `key` is present in arr.
        def mdig?(key, arr)
          arr.include?(key)
        end

        def stats_opt(category, action)
          {category: category, action: action}
        end
      end
    end
  end
end
