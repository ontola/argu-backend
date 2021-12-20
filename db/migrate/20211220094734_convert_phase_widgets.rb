class ConvertPhaseWidgets < ActiveRecord::Migration[6.1]
  def change
    Phase.find_each do |phase|
      ActsAsTenant.with_tenant(phase.root) do
        resource = resource_for_phase(phase)

        phase.update(resource: resource) if resource.is_a?(Edge)
      end
    end
  end

  private

  def resource_for_phase(phase)
    widgets = Widget.where(owner: phase)
    return unless widgets.count == 1

    widget = widgets.first
    return unless widget.resource_iri.count == 1

    resource_iris = widget.resource_iri.first
    return unless resource_iris.compact.count == 1

    resource_iri = resource_iris.first

    LinkedRails.iri_mapper.resource_from_iri(resource_iri, nil)
  end
end
