require "test_helper"

class JiraTeamControllerControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get jira_team_controller_index_url
    assert_response :success
  end
end
