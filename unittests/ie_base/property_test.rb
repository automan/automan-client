require File.dirname(__FILE__) + "/setup"

class ButtonTest < Test::Unit::TestCase
  def test_check_content
    page = start("selector")
    assert_equal(page.current.control,"page-root(bridge)")
    ele = page.find_element(FElement, "a#id2")
    @struct = ele.element
    puts JavascriptLibrary.callEmbeddedSelenium(@struct.bridge, "getTagName", @struct.element)
 
    assert_equal(ele.id,"id2")

    ele = page.find_element(FElement, "a[name=link_name]")
    assert_equal(ele.get("name"),"link_name")

    ele = page.find_element(FElement, "a[title=link_title]")
    assert_equal(ele.get("title"),"link_title")

    ele = page.find_element(FElement, "a#id2")
    assert_equal(ele.text,"Link Using an ID2")
  end
end 