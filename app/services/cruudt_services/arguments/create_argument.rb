# frozen_string_literal: true

class CreateArgument < CreateEdge
  private

  def assign_attributes # rubocop:disable Metrics/AbcSize
    super
    klass = resource.pro ? ProArgument : ConArgument
    became = resource.becomes(klass)
    became.owner_type = klass.sti_name
    became.properties = resource.properties
    became.parent = resource.parent
    became.argu_publication = resource.argu_publication
    became.instance_variable_set(:@mutations_from_database, resource.send(:mutations_from_database))
    @edge = became
  end
end
