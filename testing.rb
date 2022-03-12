require "minitest/autorun"
require_relative "expensable"

class RelatedClassTest < Minitest::Test
  def test_is_a_instance?
    var = Expensable.new
    assert_instance_of(Expensable, var)
  end

  def test_login
    data = { email: "test3@mail.com", password: "123456" }
    respuesta = Sessions.login(data)

    assert_equal "test3@mail.com", respuesta[:email]
    assert_equal "Test", respuesta[:first_name]
    assert_equal "User", respuesta[:last_name]
  end

  def test_signup
    random = rand(100..150)
    data = { email: "test#{random}@mail.com", password: "123456", first_name: "pedrito", last_name: "picapiedra",
             phone: "999606060" }
    respuesta = Sessions.signup(data)
    assert_equal "test#{random}@mail.com", respuesta[:email]
    assert_equal "pedrito", respuesta[:first_name]
    assert_equal "picapiedra", respuesta[:last_name]
    assert_equal "999606060", respuesta[:phone]
  end

  def test_print_menuu
    menu = Expensable.new.print_menu(:menu_login)
    assert_equal "login | create_user | exit", menu
  end

  def test_error
    data = { email: "test#{rand(150..200)}@mail.com", password: "123456" }
    assert_raises(HTTParty::ResponseError) { Sessions.login(data) }
  end
end
