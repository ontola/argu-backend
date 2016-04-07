require 'test_helper'

class PhaseTest < ActiveSupport::TestCase
  let(:project) { create(:project) }
  subject{ create(:phase, id: 1, project: project, forum: project.forum) }
  let!(:next_phase) { create(:phase, id: 2, project: project, forum: project.forum) }

  test 'valid' do
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'Update start_date of next phase' do
    subject
    project.phases.reload
    assert_equal subject, project.phases.first
    assert_equal next_phase, subject.next_phase
    assert_equal subject.end_date, nil
    assert_equal next_phase.start_date, nil

    # set start date of first phase to start date of project
    project.update(start_date: DateTime.yesterday)
    subject.reload
    assert_equal subject.start_date, project.start_date

    # set start date of second phase to end date of first phase
    subject.update(end_date: DateTime.tomorrow)
    project.phases.reload
    next_phase.reload
    assert_equal subject.end_date, next_phase.start_date

    # don't set start date of project after end date of first phase
    assert_not project.update(start_date: 1.month.from_now)

    # don't set end date of first project after end date of second phase
    next_phase.update(end_date: 2.days.from_now)
    subject.next_phase.reload
    assert_not subject.update(end_date: 1.month.from_now)

    # don't set end date of second phase before end date of first phase
    assert_not next_phase.update(end_date: DateTime.now)

    # set end date of project to end date of last phase
    next_phase.update(end_date: 1.year.from_now)
    project.reload
    assert_equal next_phase.end_date.to_i, project.end_date.to_i
  end
end
