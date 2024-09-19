require "test_helper"

class JiraFiltersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get jira_filters_index_url
    assert_response :success
  end

  test "should get show" do
    get jira_filters_show_url
    assert_response :success
  end
end
