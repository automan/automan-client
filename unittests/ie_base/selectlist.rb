require File.dirname(__FILE__) + "/setup"

class SelectListTests < Test::Unit::TestCase
  def test_regex_select
    page = start("selectboxes1")
    sl = page.find_element(ASelectList, "*[name=sel1]")
    sl.set(/2/)
    assert_equal "Option 2", sl.selected_value
    page.close
  end
  def test_text_select
    page = start("selectboxes1")
    sl = page.find_element(ASelectList, "*[name=sel1]")
    sl.set("Option 2")
    assert_equal "Option 2", sl.selected_value
    page.close
  end
end