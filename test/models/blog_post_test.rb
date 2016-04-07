require 'test_helper'

class BlogPostTest < ActiveSupport::TestCase
  let(:project) { create(:project, start_date: DateTime.yesterday, end_date: DateTime.tomorrow) }
  subject{ create(:blog_post, blog_postable: project, forum: project.forum) }
  test 'valid' do
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'Update start_date of next phase' do
    # don't publish blog_post before start_date of project
    assert_not subject.update(published_at: 1.month.ago)
    # don't publish blog_post after end_date of project
    assert_not subject.update(published_at: 1.month.from_now)
    # publish blog_post within scope of project
    assert subject.update(published_at: DateTime.now)
    # publish blog_post in future when project has no end_Date
    subject.blog_postable.update(end_date: nil)
    assert subject.update(published_at: 1.month.from_now)
  end
end
