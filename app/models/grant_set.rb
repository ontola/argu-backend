# frozen_string_literal: true
class GrantSet
  GRANT_SETS = YAML.safe_load(File.read(Rails.root.join('config', 'grant_sets.yml'))).with_indifferent_access.freeze
  ROLES = {custom: -1, none: 0, spectate: 1, participate: 2, initiate: 3, moderate: 4, administrate: 5}.freeze

  attr_accessor :edge_id
  attr_accessor :group_id
  attr_accessor :role

  def initialize(opts = {})
    self.edge_id = opts.fetch(:edge_id)
    self.group_id = opts.fetch(:group_id)
    self.role = opts[:role]
  end

  def role
    @role ||= current_role
  end

  # Destroys all grants on the given Edge and created Grants belonging to the current role in return
  def create_grants
    current_grants.destroy_all
    Grant.create!(grants_attributes(expected_grants(role)))
  end

  private

  def current_role
    return :none if current_grants.empty?
    set = current_grants.pluck(:edge_id, :group_id, :model_type, :parent_type, :action, :permit).to_set
    current_role = ROLES.except(:custom, :none).keys.detect do |r|
      grants_attributes(expected_grants(r)).map(&:values).to_set == set
    end
    current_role || :custom
  end

  def current_grants
    Grant.where(edge_id: edge_id, group_id: group_id, role: nil)
  end

  def expected_grants(role)
    return [] if role.nil? || role == :custom
    Hash[
      GRANT_SETS.map do |model_type, actions|
        grants = Hash[
          actions.map do |action, grant_sets|
            parent_types =
              case grant_sets[role]
              when true
                %w(*)
              when false
                []
              else
                grant_sets[role].keys.map(&:classify)
              end
            [action, parent_types]
          end
        ]
        [model_type, grants]
      end
    ]
  end

  def grants_attributes(grants)
    grants.map do |model_type, actions|
      actions.map do |action, parent_types|
        next unless parent_types.any?
        parent_types.map do |parent_type|
          {
            edge_id: edge_id,
            group_id: group_id,
            model_type: model_type.classify,
            parent_type: parent_type.classify,
            action: action,
            permit: true
          }
        end
      end.compact
    end.flatten
  end
end
