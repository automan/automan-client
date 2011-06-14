require File.dirname(__FILE__) + "/setup"

class RadioTests < Test::Unit::TestCase
  def test_new_set_true
    page = start("radioButtons1")
    r = page.find_element(ARadio, "#box5")
    r.set
    assert_equal(true, r.checked)
    page.close
  end
  def test_new_set_false
    page = start("radioButtons1")
    r = page.find_element(ARadio, "#box5")
    r.clear
    assert_equal(false, r.checked)
    page.close
  end
end