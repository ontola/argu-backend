class ConvertRIVMModelsToTags < ActiveRecord::Migration[6.0]
  def change
    return unless Apartment::Tenant.current == 'rivm'

    ActsAsTenant.current_tenant = Page.find_via_shortname('omgevingsveiligheid')
    phase_fragments = [180, 179, 178, 177, 176, 173]

    service_options = {
      publisher: User.community,
      creator: ActsAsTenant.current_tenant.profile
    }
    category_attrs = {
      owner_type: 'Vocabulary',
      display_name: 'Categorieën',
      url: 'categorieen',
      tagged_label: 'Voorbeelden'
    }
    categories = CreateEdge.new(
      ActsAsTenant.current_tenant,
      attributes: category_attrs,
      options: service_options
    ).commit
    phases_attrs = {
      owner_type: 'Vocabulary',
      display_name: 'Fases',
      url: 'fases',
      tagged_label: 'Voorbeelden'
    }
    phases = CreateEdge.new(
      ActsAsTenant.current_tenant,
      attributes: phases_attrs,
      options: service_options
    ).commit

    [Category, MeasureType, Risk].each do |klass|
      klass.find_each do |record|
        if phase_fragments.include?(record.fragment)
          record.update(owner_type: 'Term', parent: phases)
        else
          record.update(owner_type: 'Term', parent: categories)
        end
      end
    end

    Measure.find_each do |record|
      is_phase = phase_fragments.include?(record.parent.fragment)
      category_ids = is_phase ? [] : [record.parent.uuid]
      phase_ids = is_phase ? [record.parent.uuid] : []

      record.update(
        parent: ActsAsTenant.current_tenant,
        category_ids: category_ids,
        phase_ids: phase_ids
      )
    end
  end
end
