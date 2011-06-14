require File.dirname(__FILE__) + "/setup"

class PopWinTest < Test::Unit::TestCase
  def test_check_content
    ie = IEModel.start("http://www.w3schools.com/js/tryit.asp?filename=tryjs_alert")
    ppage=ie.cast(HtmlModel)
    ele = ppage.find_element(ANoWaitElement, "iframe input[type=button]")
    assert_equal(ele.get("value"), "Show alert box")
    ele.click
    text = get_content()
    assert_equal(text, "Hello! I am an alert box!")
    deal_dialog("È·¶¨")
    ie.close
  end
end