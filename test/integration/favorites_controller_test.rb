# frozen_string_literal: true
require 'test_helper'

class FavoritesControllerTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects
  let!(:subject) { create(:favorite, user: user, edge: freetown.edge) }

  def destroy_path(record)
    url_for([record.edge.owner, model_class])
  end

  define_tests do
    hash = {}
    define_test(hash, :create, options: {parent: :freetown, differences: [['Favorite', 1]]}) do
      user_types[:create].merge(user: exp_res(should: false))
    end
    define_test(hash, :destroy, options: {differences: [['Favorite', -1]]}) do
      {
        guest: exp_res(asserts: [assert_not_a_user], analytics: false),
        user: exp_res(should: true)
      }
    end
  end
end
