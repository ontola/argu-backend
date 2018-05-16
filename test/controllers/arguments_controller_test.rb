# frozen_string_literal: true

require 'test_helper'

class ArgumentsControllerTest < ActionController::TestCase
  define_freetown
  define_holland
  let(:motion) { create(:motion, :with_arguments, :with_votes, parent: freetown.edge) }
  let(:non_persisted_linked_record) { LinkedRecord.new_for_forum(freetown.page.url, freetown.url, SecureRandom.uuid) }
  let(:linked_record) do
    lr = LinkedRecord.create_for_forum(freetown.page.url, freetown.url, SecureRandom.uuid)
    create(:argument, :with_comments, parent: lr.edge)
    create(:argument, :with_comments, parent: lr.edge, pro: false)
    create(:argument, :with_comments, parent: lr.edge, edge_attributes: {trashed_at: Time.current})
    lr
  end
  let(:non_persisted_linked_record_base) { non_persisted_linked_record.iri.to_s.gsub('/od/', '/lr/') }
  let(:linked_record_base) { linked_record.iri.to_s.gsub('/od/', '/lr/') }
  let(:argument) { create(:argument, :with_comments, parent: motion.edge) }

  ####################################
  # Show
  ####################################
  test 'should get show argument' do
    get :show, params: {format: :json_api, root_id: argu.url, id: argument.edge.fragment}
    assert_redirected_to argument.iri_path
  end
end
