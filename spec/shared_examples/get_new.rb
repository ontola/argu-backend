# frozen_string_literal: true

RSpec.shared_examples_for 'get new' do |opts = {skip: []}|
  let(:r_param) { new_path }

  (new_formats - (opts[:skip] || [])).each do |format|
    context "as #{format}" do
      unless opts[:skip].include?(:new_guest) || opts[:skip].include?(:guest)
        it 'as guest' do
          sign_in(:guest, doorkeeper_application)
          get new_path, headers: {accept: Mime::Type.lookup_by_extension(format).to_s}
          send("expect_get_form_guest_#{format}")
        end
      end

      unless opts[:skip].include?(:new_unauthorized) || opts[:skip].include?(:unauthorized)
        it 'as unauthorized' do
          sign_in(unauthorized_user, doorkeeper_application)
          get new_path, headers: {accept: Mime::Type.lookup_by_extension(format).to_s}
          send("expect_get_form_unauthorized_#{format}")
        end
      end

      unless opts[:skip].include?(:new_authorized) || opts[:skip].include?(:authorized)
        it 'as authorized' do
          sign_in(authorized_user, doorkeeper_application)
          get new_path, headers: {accept: Mime::Type.lookup_by_extension(format).to_s}
          send("expect_get_form_#{format}")
        end
      end

      unless opts[:skip].include?(:new_non_existing) || opts[:skip].include?(:non_existing)
        it 'non existing parent' do
          sign_in(authorized_user, doorkeeper_application)
          get non_existing_new_path, headers: {accept: Mime::Type.lookup_by_extension(format).to_s}
        end
      end
    end
  end
end
