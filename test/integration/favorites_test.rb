# frozen_string_literal: true
require 'test_helper'

class FavoritesTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects
  let!(:subject) { create(:favorite, user: user, edge: freetown.edge) }

  def destroy_path(record)
    url_for([record.edge.owner, model_class])
  end

  def general_create(results: {},
                     parent: nil,
                     attributes: {},
                     differences: [[model_class.to_s, 1],
                                   ['Activity.loggings', model_class.is_publishable? ? 2 : 1]],
                     **opts)
    Favorite.destroy_all
    super
  end

  define_tests do
    hash = {}
    define_test(hash, :create, options: {parent: :freetown, differences: [['Favorite', 1]]})
    define_test(hash, :destroy, options: {differences: [['Favorite', -1]]}) do
      {
        guest: exp_res(response: 302, asserts: [assert_not_a_user], analytics: false),
        user: exp_res(response: 303, should: true)
      }
    end
  end
end
