require 'test_helper'

class BlogPostTest < ActiveSupport::TestCase
  let(:project) { create(:project, start_date: DateTime.yesterday, end_date: DateTime.tomorrow) }
  subject{ create(:blog_post, blog_postable: project, forum: project.forum) }
  test 'valid' do
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'Update start_date of next phase' do
    assert_not subject.update(published_at: 1.month.ago),
               'blog_post can be published before start_date of project'
    assert_not subject.update(published_at: 1.month.from_now),
               'blog_post can be published after end_date of project'
    assert subject.update(published_at: DateTime.current),
           "blog_post can't be published while within scope of project"
    subject.blog_postable.update(end_date: nil)
    assert subject.update(published_at: 1.month.from_now),
           "blog_post can't be published in future while project has no end_date"
  end
end
