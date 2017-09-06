# frozen_string_literal: true

RSpec.shared_examples_for 'get new' do |opts = {skip: []}|
  let(:r_param) { new_path }

  unless opts[:skip].include?(:new_guest) || opts[:skip].include?(:guest)
    it 'as guest' do
      sign_out
      get new_path
      expect_redirect_to_login
    end
  end

  unless opts[:skip].include?(:new_unauthorized) || opts[:skip].include?(:unauthorized)
    it 'as unauthorized' do
      sign_in(unauthorized_user)
      get new_path
      expect_unauthorized
    end
  end

  unless opts[:skip].include?(:new_authorized) || opts[:skip].include?(:authorized)
    it 'as authorized' do
      sign_in(authorized_user)
      get new_path
      expect_get_new
    end
  end

  unless opts[:skip].include?(:new_non_existing) || opts[:skip].include?(:non_existing)
    it 'non existing parent' do
      sign_in(authorized_user)
      get non_existing_new_path
      expect_not_found
    end
  end
end
