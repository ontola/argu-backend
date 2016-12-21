# frozen_string_literal: true
class AnalyticsListener
  include AnalyticsHelper

  def initialize(opts = {})
    @uuid = opts[:uuid]
    @client_id = opts[:client_id]
  end

  %i(project question motion argument comment blog_post).each do |model|
    define_method "create_#{model}_successful" do |_|
      send_event uuid: @uuid,
                 client_id: @client_id,
                 type: 'event',
                 category: model.to_s.pluralize,
                 action: 'create_success'
    end

    define_method "create_#{model}_failed" do |_|
      send_event uuid: @uuid,
                 client_id: @client_id,
                 type: 'event',
                 category: model.to_s.pluralize,
                 action: 'create_failed'
    end

    define_method "trash_#{model}_successful" do |_|
      send_event uuid: @uuid,
                 client_id: @client_id,
                 type: 'event',
                 category: model.to_s.pluralize,
                 action: 'trash_success'
    end

    define_method "destroy_#{model}_successful" do |_|
      send_event uuid: @uuid,
                 client_id: @client_id,
                 type: 'event',
                 category: model.to_s.pluralize,
                 action: 'destroy_success'
    end

    define_method "destroy_#{model}_failed" do |_|
      send_event uuid: @uuid,
                 client_id: @client_id,
                 type: 'event',
                 category: model.to_s.pluralize,
                 action: 'destroy_failed'
    end
  end

  def create_group_membership_successful(resource)
    send_event uuid: @uuid,
               client_id: @client_id,
               type: 'event',
               category: 'memberships',
               action: 'create',
               label: resource.try(:name)
  end

  def create_vote_successful(resource)
    method = resource.created_at == resource.updated_at ? 'create' : 'update'
    send_event uuid: @uuid,
               client_id: @client_id,
               type: 'event',
               category: 'votes',
               action: method,
               label: resource.for
  end

  def destroy_group_membership_successful(resource)
    send_event uuid: @uuid,
               client_id: @client_id,
               type: 'event',
               category: 'memberships',
               action: 'destroy',
               label: resource.try(:name)
  end
end
