# frozen_string_literal: true

RSpec.shared_examples_for 'get index' do |opts = {skip: []}|
  let(:r_param) { index_path }

  unless opts[:skip].include?(:index_guest) || opts[:skip].include?(:guest)
    it 'as guest' do
      sign_out
      get index_path, params: {format: request_format}
      send("expect_get_index_guest_#{request_format}")
    end
  end

  unless opts[:skip].include?(:index_unauthorized) || opts[:skip].include?(:unauthorized)
    it 'as unauthorized' do
      sign_in(unauthorized_user)
      get index_path, params: {format: request_format}
      send("expect_get_index_unauthorized_#{request_format}")
    end
  end

  unless opts[:skip].include?(:index_authorized) || opts[:skip].include?(:authorized)
    it 'as authorized' do
      sign_in(authorized_user)
      get index_path, params: {format: request_format}
      send("expect_get_index_#{request_format}")
    end
  end

  unless opts[:skip].include?(:index_non_existing) || opts[:skip].include?(:non_existing)
    it 'non existing parent' do
      sign_in(authorized_user)
      get non_existing_index_path, params: {format: request_format}
      expect_not_found
    end
  end
end
