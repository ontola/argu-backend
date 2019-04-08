class CreateDataCatalogGrants < ActiveRecord::Migration[5.2]
  def change
    @actions = HashWithIndifferentAccess.new
    %w[data_catalog dataset distribution].each do |type|
      %w[create show update destroy trash].each do |action|
        @actions["#{type}_#{action}"] =
          PermittedAction.create!(
            title: "#{type}_#{action}",
            resource_type: type.classify,
            parent_type: '*',
            action: action
          )
      end
    end

    GrantSet.where(root_id: nil).find_each do |grant_set|
      actions = [@actions[:data_catalog_show], @actions[:dataset_show], @actions[:distribution_show]]
      if grant_set.title == 'staff'
        actions << [@actions[:data_catalog_create], @actions[:data_catalog_update], @actions[:data_catalog_destroy]]
        actions << [@actions[:dataset_create], @actions[:dataset_update], @actions[:dataset_destroy]]
        actions << [@actions[:distribution_create], @actions[:distribution_update], @actions[:distribution_destroy]]
      end
      grant_set.permitted_actions << actions
      grant_set.save!(validate: false)
    end
  end
end
