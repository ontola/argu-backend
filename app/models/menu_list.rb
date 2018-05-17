# frozen_string_literal: true

class MenuList
  include ActiveModel::Model
  include Ldable
  include Iriable
  include ActionDispatch::Routing
  include Rails.application.routes.url_helpers
  include Pundit

  attr_accessor :resource, :label, :user_context
  delegate :user, to: :user_context

  alias read_attribute_for_serialization send
  alias current_user user_context

  def custom_menu_items(menu_type, resource)
    CustomMenuItem
      .where(menu_type: menu_type, resource_type: resource.class.name, resource_id: resource.uuid)
      .order(:order)
      .map do |menu_item|
      menu_item(
        "custom_#{menu_item.id}",
        label: menu_item.label,
        image: menu_item.image,
        href: menu_item.href,
        policy: menu_item.policy
      )
    end
  end

  def iri(opts = {})
    RDF::URI(expand_uri_template('menu_lists_iri', opts.merge(parent_iri: resource.iri(only_path: true))))
  end

  def self.has_menus(menus)
    self.defined_menus = menus
  end

  def menus
    defined_menus.map { |menu| send("#{menu}_menu") }
  end

  def menu
    Hash[defined_menus.map { |menu| [menu, send("#{menu}_menu")] }]
  end

  private

  def menu_item(tag, options)
    if options[:policy].present?
      return unless resource_policy(options[:policy_resource]).send(options[:policy], *options[:policy_arguments])
    end
    options[:label_params] ||= {}
    options[:label] ||= I18n.t("menus.#{resource&.class_name}.#{tag}",
                               options[:label_params]
                                 .merge(default: ["menus.default.#{tag}".to_sym, tag.to_s.capitalize]))
    options.except!(:policy_resource, :policy, :policy_arguments, :label_params)
    MenuItem.new(resource: resource, tag: tag, parent: self, **options)
  end

  def resource_policy(policy_resource)
    policy_resource ||= resource
    @resource_policy ||= {}
    @resource_policy[policy_resource.identifier] ||= policy(policy_resource)
  end
end
