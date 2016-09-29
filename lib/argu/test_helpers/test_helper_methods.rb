# frozen_string_literal: true
require 'argu/test_helpers/test_resources'

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
        SERVICE_MODELS = %i(argument blog_post comment forum group_membership motion
                            phase banner group project question vote decision).freeze

        def assert_analytics_collected(category = nil, action = nil, label = nil, **options)
          category ||= options[:category]
          action ||= options[:action]
          label ||= options[:label]
          assert_requested :post, 'https://ssl.google-analytics.com/collect' do |req|
            el = CGI.parse(req.body)['el'].first if label
            ea = CGI.parse(req.body)['ea'].first if action
            ec = CGI.parse(req.body)['ec'].first.to_s
            category == ec && (action ? action == ea : true) && (label ? label.to_s == el : true)
          end
        end

        def assert_analytics_not_collected
          assert_not_requested(
            stub_request(:post, 'https://ssl.google-analytics.com/collect')
              .with(body: /(&ea=(?!sign_in)){1}/)
          )
        end

        def assert_not_a_member
          assert_equal true, assigns(:_not_a_member_caught)
        end

        def assert_not_a_user
          assert_equal true, assigns(:_not_a_user_caught)
        end

        def assert_not_authorized
          assert_equal true, assigns(:_not_authorized_caught)
        end

        def cascaded_forum(key, opts)
          key && opts.dig(key, :forum) || opts.dig(:forum) || try(:freetown)
        end

        def change_actor(actor)
          a = actor.respond_to?(:profile) ? actor.profile : actor
          @controller.instance_variable_set(:@_current_actor, a)
          cookies['a_a'] = actor.profile.id
        end

        def create(model_type, *args)
          attributes = HashWithIndifferentAccess.new
          attributes.merge!(args.pop) if args.last.is_a?(Hash)
          traits_with_args = attributes.delete(:traits_with_args) || {}
          if SERVICE_MODELS.include?(model_type)
            klass = model_type.to_s.classify.constantize

            options = attributes.delete(:options) || {}
            options[:publisher] ||= attributes.delete(:publisher)
            options[:creator] ||= attributes.delete(:creator)

            attributes.merge!(attributes_for(model_type, attributes))

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
              options)

            args.each do |trait|
              TraitListener.new(resource).public_send(trait)
            end
            traits_with_args.each do |trait|
              TraitListener.new(resource).public_send(trait[0], trait[1])
            end

            if resource.respond_to?(:publications) && resource.publications.present?
              if Publication.last.published_at.present? && Publication.last.published_at <= 10.seconds.from_now
                Sidekiq::Testing.inline! do
                  Publication.last.send(:reset)
                end
              else
                Publication.last.send(:reset)
              end
              resource.reload
            end

            resource
          else
            FactoryGirl.create(model_type, *args, attributes)
          end
        end

        def create_manager(item, user = nil)
          user ||= create(:user)
          create(:group_membership,
                 parent: item.managers_group.edge,
                 shortname: user.url)
          user
        end

        def create_member(forum, user = nil)
          user ||= create(:user)
          create(:group_membership,
                 parent: forum.members_group.edge,
                 shortname: user.url)
          user
        end

        def create_group_member(group, user_or_page = nil)
          user_or_page ||= create_member(group.page)
          create(:group_membership,
                 parent: group.edge,
                 shortname: user_or_page.url)
          user_or_page
        end

        def create_moderator(record, user = nil)
          user ||= create(:user)
          forum = record.is_a?(Forum) ? record : record.forum
          create(:stepup, forum: forum, record: record, moderator: create_member(forum, user))
          user
        end

        # Makes the given `User` a manager of the `Page` of the `Forum`
        # Creates one if not given
        # @note overwrites the current owner in the `Page`
        def create_owner(forum, user = nil)
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

        def create_resource(klass, attributes = {}, options = {})
          if klass != Forum
            options[:publisher] = create(:user, confirmed_at: DateTime.current) if options[:publisher].nil?
            options[:creator] = options[:publisher].profile if options[:creator].nil?
          end

          parent_edge = attributes.delete(:parent)

          service = "Create#{klass}"
                      .constantize
                      .new(parent_edge,
                           attributes: attributes,
                           options: options)
          service.commit
          service.resource.reload
        end

        def destroy_resource(resource, user = nil, profile = nil)
          user ||= create(:user)
          profile ||= user.profile
          options = {}
          options[:publisher] = user
          options[:creator] = profile
          service = "Destroy#{resource.class}".constantize.new(resource, attributes: {}, options: options)
          service.subscribe(ActivityListener.new(creator: profile,
                                                 publisher: user))
          service.commit
          nil
        end

        def open_file(filename)
          File.open("test/files/#{filename}")
        end

        def stats_opt(category, action)
          {category: category, action: action}
        end

        def trash_resource(resource, user = nil, profile = nil)
          user ||= create(:user)
          profile ||= user.profile
          options = {}
          options[:publisher] = user
          options[:creator] = profile
          service = "Trash#{resource.class}".constantize.new(resource, attributes: {}, options: options)
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
          service = "Update#{resource.class}".constantize.new(resource, attributes: attributes, options: options)
          service.subscribe(ActivityListener.new(creator: profile,
                                                 publisher: user))
          service.commit
          resource.reload
        end
      end

      module ClassMethods
        include TestResources::ClassMethods

        def define_automated_tests_objects
          define_common_objects(:freetown, :user, :member, :creator, :moderator,
                                :manager, :owner, :staff, :page)
        end

        def define_common_objects(*let, **opts)
          define_freetown if mdig?(:freetown, let, opts)
          let(:user) { create(:user, opts.dig(:user)) } if mdig?(:user, let, opts)
          let(:member) { create_member(cascaded_forum(:member, opts)) } if mdig?(:member, let, opts)
          let(:creator) { create_member(cascaded_forum(:member, opts)) } if mdig?(:member, let, opts)
          let(:manager) { create_manager(cascaded_forum(:manager, opts)) } if mdig?(:manager, let, opts)
          let(:moderator) { create_moderator(cascaded_forum(:moderator, opts)) } if mdig?(:moderator, let, opts)
          let(:owner) { create_owner(cascaded_forum(:owner, opts)) } if mdig?(:owner, let, opts)
          let(:staff) { create(:user, :staff) } if mdig?(:staff, let, opts)
          let(:page) { argu } if mdig?(:page, let, opts)
        end

        def cascaded_forum(key, opts)
          key && opts.dig(key, :forum) || opts.dig(:forum) || try(:freetown)
        end

        # @param [Symbol] key The key to search for.
        # @param [Array] arr Array of options to search in.
        # @param [Hash] opts Options hash to search in.
        # @return [Boolean] Whether `key` is present in arr or hash.
        def mdig?(key, arr, opts)
          arr.include?(key) || opts.include?(key)
        end

        def stats_opt(category, action)
          {category: category, action: action}
        end
      end
    end
  end
end
