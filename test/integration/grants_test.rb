# frozen_string_literal: true
require 'test_helper'

class GrantsTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects

  let(:subject) { create(:grant, edge: freetown.edge, group: group) }
  let(:super_admin_grant) { create(:grant, edge: freetown.edge, group: group, role: :super_admin) }
  let(:group) { create(:group, parent: freetown.page.edge) }

  def default_create_attributes(parent: nil)
    super.merge(group_id: group.id, edge_id: parent.edge.id)
  end

  def create_path(parent)
    url_for([parent.page, model_class])
  end

  def new_path(parent)
    url_for([:new, parent.page, :grant, edge_id: parent.edge.id])
  end

  define_tests do
    hash = {}
    define_test(hash, :new, options: {parent: :freetown}) do
      user_types[:new].merge(
        user: exp_res,
        member: exp_res,
        manager: exp_res
      )
    end
    define_test(hash, :create, options: {parent: :freetown, differences: [['Grant', 1]]}) do
      user_types[:create].merge(
        user: exp_res,
        member: exp_res,
        manager: exp_res
      )
    end
    define_test(hash, :destroy, options: {differences: [['Grant', -1]]}) do
      user_types[:destroy].merge(
        manager: exp_res
      )
    end
    define_test(hash, :destroy, options: {record: :super_admin_grant}) do
      {staff: exp_res}
    end
  end
end
