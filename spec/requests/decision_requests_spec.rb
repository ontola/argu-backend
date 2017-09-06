# frozen_string_literal: true

require 'rails_helper'
require 'argu/test_helpers/automated_requests'

RSpec.describe 'Decisions', type: :request do
  include Argu::TestHelpers::AutomatedRequests
  include DecisionsHelper

  let(:new_path) { url_for([:new, subject.parent_model, class_sym, only_path: true]) }
  let(:edit_path) { url_for([:edit, subject.parent_model, :decision, id: subject.step, only_path: true]) }
  let(:show_path) { url_for([subject.parent_model, :decision, id: subject.step, only_path: true]) }
  let(:create_path) { url_for([subject.parent_model, table_sym, only_path: true]) }
  let(:update_path) { url_for([subject.parent_model, :decision, id: subject.step, only_path: true]) }
  let(:non_existing_new_path) do
    url_for([:new, parent_class_sym, class_sym, "#{parent_class_sym}_id".to_sym => -1, only_path: true])
  end
  let(:non_existing_edit_path) { url_for([:edit, subject.parent_model, :decision, id: -1, only_path: true]) }
  let(:non_existing_show_path) { url_for([subject.parent_model, :decision, id: -1, only_path: true]) }
  let(:non_existing_create_path) do
    url_for([parent_class_sym, table_sym, "#{parent_class_sym}_id".to_sym => -1, only_path: true])
  end
  let(:non_existing_update_path) { url_for([subject.parent_model, :decision, id: -1, only_path: true]) }
  let(:created_resource_path) { parent_path }
  let(:updated_resource_path) { parent_path }

  let(:authorized_user) { subject.forwarded_user }
  let(:create_params) do
    {
      decision: attributes_for(
        :decision,
        state: 'approved',
        content: 'Content',
        happening_attributes: {happened_at: Time.current}
      )
    }
  end
  let(:required_keys) { %w[content] }

  subject { decision }
  it_behaves_like 'requests', skip: %i[trash untrash delete destroy update_invalid]
end
