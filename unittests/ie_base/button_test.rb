require File.dirname(__FILE__) + "/setup"

class ButtonTest < Test::Unit::TestCase
  def test_check_content
    page = start("buttons1")
    page.find_element(AButton,"button[type=submit]").click
    assert_equal "Pass Page", page.ie.title
    page.close
  end
end