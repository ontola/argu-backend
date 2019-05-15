# frozen_string_literal: true

class PageSerializer < RecordSerializer
  include ProfilePhotoable::Serializer

  attribute :name, predicate: NS::SCHEMA[:name]
  attribute :about, predicate: NS::SCHEMA[:description]
  attribute :visibility, predicate: NS::ARGU[:visibility]
  attribute :url, predicate: NS::ARGU[:shortname], datatype: NS::XSD[:string]
  attribute :follows_count, predicate: NS::ARGU[:followsCount]

  has_one :primary_container_node, predicate: NS::FOAF[:homepage], unless: :service_scope?
  has_one :profile, predicate: NS::ARGU[:profile]

  enum :visibility

  with_collection :container_nodes, predicate: NS::ARGU[:forums]

  def about
    object.profile.about
  end

  def name
    object.profile.name
  end

  def object
    super.is_a?(Profile) ? super.profileable : super
  end

  def primary_container_node
    EdgePolicy::Scope.new(scope, object.container_nodes).resolve.first if ActsAsTenant.current_tenant
  end

  def default_profile_photo
    object.profile.default_profile_photo
  end

  def widget_sequence
    super if ActsAsTenant.current_tenant == object
  end
end
