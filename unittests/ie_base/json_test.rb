require File.dirname(__FILE__) + "/setup"

class ButtonTest < Test::Unit::TestCase
  #在web_driver中使用
  def test_json
    p = ["taichan"]
    args = {:args => p}
    j = args.to_json
    puts j #应该没有异常
  end

  def test_callEmbeddedSelenium
    page = start("selector")
    ele = page.find_element(FElement, "a#id2")
    @struct = ele.element
    assert_equal("a", JavascriptLibrary.callEmbeddedSelenium(@struct.bridge, "getTagName", @struct.element))
  end
end
