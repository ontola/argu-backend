# frozen_string_literal: true
class AnalyticsListener
  include AnalyticsHelper

  def initialize(opts = {})
    @uuid = opts[:uuid]
    @client_id = opts[:client_id]
  end

  %i(project question motion argument comment blog_post).each do |model|
    define_method "create_#{model}_successful" do |_|
      send_analytics_event 'create_success', model
    end

    define_method "create_#{model}_failed" do |_|
      send_analytics_event 'create_failed', model
    end

    define_method "trash_#{model}_successful" do |_|
      send_analytics_event 'trash_success', model
    end

    define_method "destroy_#{model}_successful" do |_|
      send_analytics_event 'destroy_success', model
    end

    define_method "destroy_#{model}_failed" do |_|
      send_analytics_event 'destroy_failed', model
    end
  end

  def create_group_membership_successful(resource)
    send_analytics_event 'create', 'memberships', resource.try(:name)
  end

  def create_vote_successful(resource)
    method = resource.created_at == resource.updated_at ? 'create' : 'update'
    send_analytics_event method, 'votes', resource.for
  end

  def destroy_group_membership_successful(resource)
    send_analytics_event 'destroy', 'membership', resource.try(:name)
  end

  private

  def send_analytics_event(action, category, label = nil)
    send_event uuid: @uuid,
               client_id: @client_id,
               type: 'event',
               category: category.to_s.pluralize,
               action: action,
               label: label
  end
end
