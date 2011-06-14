require File.dirname(__FILE__) + "/setup"

class CheckBoxTests < Test::Unit::TestCase
  def	test_new_set_true
    page = start("checkboxes1")
    e = page.find_element(ACheckBox, "#box4")
    e.set
    assert(e.checked)
    page.close
  end
  def	test_new_set_false
    page = start("checkboxes1")
    e = page.find_element(ACheckBox, "input[name=box5]")
    e.clear
    assert(!e.checked)
    page.close
  end
end