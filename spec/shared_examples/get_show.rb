# frozen_string_literal: true

RSpec.shared_examples_for 'get show' do |opts = {skip: []}|
  unless opts[:skip].include?(:show_guest) || opts[:skip].include?(:guest)
    it 'as guest' do
      sign_out
      get show_path, params: {format: request_format}
      send("expect_get_show_guest_#{request_format}")
    end
  end

  unless opts[:skip].include?(:show_unauthorized) || opts[:skip].include?(:unauthorized)
    it 'as unauthorized' do
      sign_in(unauthorized_user)
      get show_path, params: {format: request_format}
      send("expect_get_show_unauthorized_#{request_format}")
    end
  end

  unless opts[:skip].include?(:show_authorized) || opts[:skip].include?(:authorized)
    it 'as authorized' do
      sign_in(authorized_user_update)
      get show_path, params: {format: request_format}
      send("expect_get_show_#{request_format}")
    end
  end

  unless opts[:skip].include?(:show_non_existing) || opts[:skip].include?(:non_existing)
    it 'non existing' do
      sign_in(authorized_user_update)
      get non_existing_show_path, params: {format: request_format}
      expect_not_found
    end
  end
end
