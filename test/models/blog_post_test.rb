# frozen_string_literal: true

require 'test_helper'

class BlogPostTest < ActiveSupport::TestCase
  define_freetown
  subject do
    create(:blog_post,
           happening_attributes: {happened_at: Time.current},
           parent: question)
  end
  let(:question) { create(:question, parent: freetown) }

  test 'valid' do
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end
