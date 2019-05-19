require 'test_helper'

class UsersTest < ActionDispatch::IntegrationTest
  test "should sign up" do
    post auth_register_path, params: {user: {email: "email@email.com", password: "password"}}
    assert_response :created
  end

  test "should login" do
    post auth_login_path, params: {auth: {email: "one@one.com", password: "onepass"}}
    assert_response :created
  end

  test "should not login with wrong password" do
    post auth_login_path, params: {auth: {email: "one@one.com", password: "passpass"}}
    assert_response :not_found
  end
end
