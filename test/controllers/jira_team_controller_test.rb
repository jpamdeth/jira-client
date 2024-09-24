require "test_helper"

class JiraTeamControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get jira_team_index_url
    assert_response :success
  end
end
