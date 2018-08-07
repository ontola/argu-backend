# frozen_string_literal: true

RSpec.shared_examples_for 'get edit' do |opts = {skip: []}|
  let(:r_param) { edit_path }

  (edit_formats - (opts[:skip] || [])).each do |format|
    context "as #{format}" do
      unless opts[:skip].include?(:edit_guest) || opts[:skip].include?(:guest)
        it 'as guest' do
          sign_out
          get edit_path, headers: {accept: Mime::Type.lookup_by_extension(format).to_s}
          send("expect_get_form_guest_#{format}")
        end
      end

      unless opts[:skip].include?(:edit_unauthorized) || opts[:skip].include?(:unauthorized)
        it 'as unauthorized' do
          sign_in(unauthorized_user)
          get edit_path, headers: {accept: Mime::Type.lookup_by_extension(format).to_s}
          send("expect_get_form_unauthorized_#{format}")
        end
      end

      unless opts[:skip].include?(:edit_authorized) || opts[:skip].include?(:authorized)
        it 'as authorized' do
          sign_in(authorized_user_update)
          get edit_path, headers: {accept: Mime::Type.lookup_by_extension(format).to_s}
          send("expect_get_form_#{format}")
        end
      end

      unless opts[:skip].include?(:edit_non_existing) || opts[:skip].include?(:non_existing)
        it 'non existing' do
          sign_in(authorized_user_update)
          get non_existing_edit_path, headers: {accept: Mime::Type.lookup_by_extension(format).to_s}
        end
      end
    end
  end
end
