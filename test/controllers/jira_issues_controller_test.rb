require "test_helper"

class JiraIssuesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get jira_issues_index_url
    assert_response :success
  end

  test "should get show" do
    get jira_issues_show_url
    assert_response :success
  end

  test "should get new" do
    get jira_issues_new_url
    assert_response :success
  end

  test "should get create" do
    get jira_issues_create_url
    assert_response :success
  end
end
