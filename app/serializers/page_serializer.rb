# frozen_string_literal: true

class PageSerializer < RecordSerializer
  attribute :name, predicate: NS::FOAF[:name], datatype: NS::XSD[:string]
  attribute :url, predicate: NS::ARGU[:shortname], datatype: NS::XSD[:string]
  attribute :follows_count, predicate: NS::ARGU[:followsCount]
  attribute :last_accepted, predicate: NS::ARGU[:lastAccepted], datatype: NS::XSD[:boolean], if: :never
  attribute :database_schema, predicate: NS::ARGU[:dbSchema], if: :service_scope?

  belongs_to :primary_container_node, predicate: NS::FOAF[:homepage], unless: :service_scope?
  has_one :profile, predicate: NS::ARGU[:profile]

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

  def widget_sequence
    super if ActsAsTenant.current_tenant == object
  end
end
