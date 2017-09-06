# frozen_string_literal: true

RSpec.shared_examples_for 'delete trash' do |opts = {skip: []}|
  let(:r_param) { update_failed_path }

  unless opts[:skip].include?(:trash_guest) || opts[:skip].include?(:guest)
    it 'as guest' do
      sign_out
      delete trash_path, params: {format: request_format}
      send("expect_delete_trash_guest_#{request_format}")
    end
  end

  unless opts[:skip].include?(:trash_unauthorized) || opts[:skip].include?(:unauthorized)
    it 'as unauthorized' do
      sign_in(unauthorized_user)
      assert_differences(no_differences) do
        delete trash_path, params: {format: request_format}
      end
      send("expect_delete_trash_unauthorized_#{request_format}")
    end
  end

  unless opts[:skip].include?(:trash_authorized) || opts[:skip].include?(:authorized)
    it 'as authorized' do
      sign_in(authorized_user_trash)
      assert_differences(trash_differences) do
        delete trash_path, params: {format: request_format}
      end
      send("expect_delete_trash_#{request_format}")
    end
  end

  unless opts[:skip].include?(:trash_non_existing) || opts[:skip].include?(:non_existing)
    it 'non existing' do
      sign_in(authorized_user_trash)
      delete non_existing_trash_path, params: {format: request_format}
      expect_not_found
    end
  end
end
