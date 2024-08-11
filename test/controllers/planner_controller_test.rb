require "test_helper"

class PlannerControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get planner_index_url
    assert_response :success
  end

  test "should get show" do
    get planner_show_url
    assert_response :success
  end
end
