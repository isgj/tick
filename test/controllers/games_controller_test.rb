require 'test_helper'

class UsersTest < ActionDispatch::IntegrationTest
  def authenticated_header(user)
    token = Knock::AuthToken.new(payload: { sub: users(user).id }).token

    {
      'Authorization': "Bearer #{token}"
    }
  end

  test "should create game" do
    post api_v1_games_path, headers: authenticated_header(:one)
    assert_response :created
  end

  test "should get games" do
    get api_v1_games_path, headers: authenticated_header(:one)
    assert_response :ok
  end
end
