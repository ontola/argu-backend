# frozen_string_literal: true

require 'test_helper'

class RedirectssTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:question) { create(:question, owner_id: 1, parent: freetown.edge) }
  let(:motion) { create(:motion, owner_id: 1, parent: freetown.edge) }
  let(:pro_argument) { create(:argument, owner_id: 1, parent: motion.edge) }
  let(:con_argument) { create(:argument, owner_id: 2, parent: motion.edge, pro: false) }
  let(:comment) { create(:comment, owner_id: 1, parent: motion.edge) }
  let(:blog_post) do
    create(:blog_post, owner_id: 1, parent: motion.edge, happening_attributes: {happened_at: Time.current})
  end
  let(:decision) do
    create(
      :decision,
      owner_id: 1,
      parent: motion.edge,
      state: 'approved',
      happening_attributes: {happened_at: Time.current}
    )
  end

  #####################################################
  # Unscoped routes
  #####################################################

  test 'redirect unscoped question route' do
    get argu_url("/q/#{question.owner_id}")
    assert_redirected_to question.iri_path
  end

  test 'redirect unscoped motion route' do
    get argu_url("/m/#{motion.owner_id}")
    assert_redirected_to motion.iri_path
  end

  test 'redirect unscoped argument route' do
    get argu_url("/a/#{pro_argument.owner_id}")
    assert_redirected_to pro_argument.iri_path
  end

  test 'redirect unscoped pro_argument route' do
    get argu_url("/pro/#{pro_argument.owner_id}")
    assert_redirected_to pro_argument.iri_path
  end

  test 'redirect unscoped con_argument route' do
    get argu_url("/con/#{con_argument.owner_id}")
    assert_redirected_to con_argument.iri_path
  end

  test 'redirect unscoped blog_post route' do
    get argu_url("/posts/#{blog_post.owner_id}")
    assert_redirected_to blog_post.iri_path
  end

  test 'redirect unscoped comment route' do
    get argu_url("/c/#{comment.owner_id}")
    assert_redirected_to comment.iri_path
  end

  test 'redirect unscoped decision route' do
    get argu_url("/m/#{motion.owner_id}/decision/#{decision.step}")
    assert_redirected_to decision.iri_path
  end
end
