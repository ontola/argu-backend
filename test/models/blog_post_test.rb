# frozen_string_literal: true

require 'test_helper'

class BlogPostTest < ActiveSupport::TestCase
  define_freetown
  let(:project) do
    create(:project,
           start_date: DateTime.yesterday,
           end_date: DateTime.tomorrow,
           parent: freetown.edge)
  end
  subject do
    create(:blog_post,
           happening_attributes: {happened_at: DateTime.current},
           parent: project.edge)
  end
  test 'valid' do
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'Update start_date of next phase' do
    assert_not subject.happening.update(created_at: 1.month.ago),
               'blog_post can be published before start_date of project'
    assert_not subject.happening.update(created_at: 1.month.from_now),
               'blog_post can be published after end_date of project'
    assert subject.happening.update(created_at: DateTime.current),
           "blog_post can't be published while within scope of project"
    subject.parent_model.update(end_date: nil)
    subject.happening.reload
    assert subject.happening.update(created_at: 1.month.from_now),
           "blog_post can't be published in future while project has no end_date"
  end
end
