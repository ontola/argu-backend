# frozen_string_literal: true

# Superclass for all the services in the system
# @author Fletcher91 <thom@argu.co>
class ApplicationService # rubocop:disable Metrics/ClassLength
  include Pundit
  include Wisper::Publisher

  # @note Call super when overriding.
  def initialize(_orig_resource, attributes: {}, options: {})
    @attributes = attributes
    @actions = {}
    @options = options.except(:user_context)
    @user_context = options[:user_context]
    prepare_attributes
    assign_attributes
    prepare_nested_associations(resource)
    subscribe_listeners
  end

  attr_reader :attributes, :options, :resource, :user_context

  delegate :profile, :user, to: :user_context

  # Executes the action, so generally message broadcasts begin here.
  # @see {after_save}
  def commit # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    ActiveRecord::Base.transaction do
      persist_parents
      raise(ActiveRecord::RecordInvalid) if resource.errors.present?

      @actions[service_action] = resource.public_send(service_method)
      after_save if @actions[service_action]
      publish_success_signals
    end
    resource
  rescue ActiveRecord::ActiveRecordError => e
    raise(e) if e.is_a?(ActiveRecord::StatementInvalid)

    Bugsnag.notify(e) unless e.is_a?(ActiveRecord::RecordInvalid)
    publish("#{signal_base}_failed".to_sym, resource)
  end

  private

  # Override this when you need to perform additional actions within
  # the transaction but after the model was saved.
  # @note This doesn't work when {commit} is overridden.
  def after_save
    # Stub
  end

  def argu_publication_attributes
    pub_attrs = @attributes[:argu_publication_attributes] || {}
    if resource.argu_publication&.id&.present?
      pub_attrs[:id] = resource.argu_publication.id
    elsif !resource.is_published?
      argu_publication_attributes_for_unpublished(pub_attrs)
    end
    pub_attrs[:follow_type] = argu_publication_follow_type
    pub_attrs
  end

  def argu_publication_attributes_for_unpublished(pub_attrs)
    draft = @attributes.key?(:is_draft) ? @attributes[:is_draft] : pub_attrs[:draft]
    pub_attrs[:published_at] ||= draft.to_s == 'true' ? nil : Time.current
  end

  def argu_publication_follow_type
    important = @attributes.delete(:mark_as_important)
    return resource.argu_publication.follow_type if important.nil? && resource.argu_publication.present?

    %w[true 1].include?(important.to_s) ? :news : :reactions
  end

  def assign_attributes
    resource.assign_attributes(@attributes)
  end

  # Method to set attributes on a nested model.
  # @note This should be used for attributes that are consistent across all the associations.
  # @see {prepare_nested_associations}
  # @param [ActiveRecord::Base] obj The model on which the attributes should be set
  def assign_nested_attributes(_, _); end

  def creator
    profile
  end

  def publish_success_signals # rubocop:disable Metrics/AbcSize
    publish("#{signal_base}_successful".to_sym, resource) if @actions[service_action]
    publish("publish_#{resource.model_name.singular}_successful".to_sym, resource) if @actions[:published]
    publish("unpublish_#{resource.model_name.singular}_successful".to_sym, resource) if @actions[:unpublished]
  end

  def publisher
    user
  end

  def persist_parents
    return unless resource.try(:parent)

    while resource.parent.new_record?
      non_persisted = resource.parent
      non_persisted = non_persisted.parent until non_persisted.parent.persisted? || non_persisted.parent.nil?
      non_persisted.save!
    end
  end

  # The action that called this service.
  #
  # Used to determine the correct signal name in {signal_base} since controller
  # actions can differ from their associated model methods
  # @return [Symbol] The name of the calling controller action
  def service_action
    raise 'Required interface not implemented'
  end

  # The method that will be called on the resource
  # @return [Symbol] The method to be called on the model (Defaults to {service_action})
  def service_method
    service_action
  end

  # Calls assign_nested_attributes for each association that has been declared as `accepts_nested_attributes_for`
  # @author Fletcher91 <thom@argu.co>
  # @note Requires `assign_nested_attributes` to be overridden in the child class.
  def prepare_nested_associations(object)
    return unless object.try(:nested_attributes_options?)

    object.nested_attributes_options.each_key do |association|
      inst = object.public_send(association)
      (inst.respond_to?(:each) ? inst : [inst].compact).each do |record|
        assign_nested_attributes(object, record)
        prepare_nested_associations(record)
      end
    end
  end

  def subscribe_listeners # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    return if resource.is_a?(Activity) || resource.is_a?(Grant) || resource.try(:store_in_redis?)

    subscribe(
      ActivityListener.new(
        comment: options[:comment],
        user_context: user_context,
        notify: options[:notify]
      )
    )
    subscribe(
      NotificationListener.new,
      on: "update_#{resource.model_name.singular}_successful",
      with: :update_successful
    )
  end

  def prepare_attributes
    return unless resource.is_a?(Edge)

    prepare_argu_publication_attributes
    prepare_media_object_attributes
    @attributes.permit! if @attributes.is_a?(ActionController::Parameters)
  end

  def prepare_argu_publication_attributes
    return unless resource.is_publishable?

    @attributes[:argu_publication_attributes] = argu_publication_attributes
  end

  def prepare_media_object_attributes
    %i[cover_photo profile_photo].select { |type| @attributes.key?(:"default_#{type}_attributes") }.each do |type|
      @attributes[:"default_#{type}_attributes"]&.reverse_merge!(
        creator: creator,
        publisher: publisher,
        used_as: type
      )
    end
  end

  def signal_base
    "#{service_action}_#{resource.model_name.singular}"
  end
end
