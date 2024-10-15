require "test_helper"

class GithubControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get github_index_url
    assert_response :success
  end

  test "should get detail" do
    get github_detail_url
    assert_response :success
  end

  test "should get branches" do
    get github_branches_url
    assert_response :success
  end
end
