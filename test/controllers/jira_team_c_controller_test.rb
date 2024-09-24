require "test_helper"

class JiraTeamCControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get jira_team_c_index_url
    assert_response :success
  end
end
