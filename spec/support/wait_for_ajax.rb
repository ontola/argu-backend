require 'timeout'

module WaitForAjax

  def wait_until
    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep(0.1) until value = yield
      value
    end
  end

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def wait_for_modal
    Timeout.timeout(1000) do
      sleep(0.1) until modal_opened?
    end
  end

  def wait_for_async_modal
    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep(0.1) until finished_all_ajax_requests? && modal_opened?
    end
  end

  def modal_opened?
    save_and_open_screenshot
    page.find('body')[:class].include?('modal-opened')
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end

RSpec.configure do |config|
  config.include WaitForAjax, type: :feature
end

class ActionDispatch::IntegrationTest
  def teardown
    # detects both Prototype and jQuery AJAX requests
    active = evaluate_script('window.Ajax ? Ajax.activeRequestCount : (window.jQuery ? jQuery.active : 0)')
    assert_equal 0, active, 'Active AJAX request after test end'
  end
end
