require File.dirname(__FILE__) + "/../setup"

include AWatir
class ElementTextTest < Test::Unit::TestCase

  def setup
		goto_page("taobao.html")
  end

  def test_find_by_name_verify_text
    ie = IEModel.attach(/taobao/)
    m = ie.cast(HtmlModel)
    e = m.find_element(AWatir::ALink, ":text, 'µêÆÌ'")
    puts e.text
    assert_equal(e.text, 'µêÆÌ')
  end
  
  def test_find_by_selector_verify_text
    ie = IEModel.attach(/taobao/)
    m = ie.cast(HtmlModel)
    e = m.find_element(AWatir::AElement, "li.t-shiyi")
    puts e.text
    puts e.to_s
    assert_equal(e.text, 'ÊÔÒÂ¼ä')
  end

  def test_find_by_selector_verify_node_value
    ie = IEModel.attach(/taobao/)
    m = ie.cast(HtmlModel)
    e = m.find_element(AWatir::AElement, "ul.quick-menu>li>a:eq(0)>\\#text")
    puts e.to_s
    assert_equal(e.text, 'ÎÒÒªÂò')
  end
  
  def test_selector_get_attribute
    ie = IEModel.attach(/taobao/)
    m = ie.cast(HtmlModel)
    e = m.find_element(AWatir::AElement, "li.t-shiyi>a")
    puts e.get("href")
    assert(e.get("href")=~/shiyi.taobao.com/)
  end

    def test_text_get_attribute
    ie = IEModel.attach(/taobao/)
    m = ie.cast(HtmlModel)
    e = m.find_element(AWatir::ALink, ":text, 'ÊÔÒÂ¼ä'")
    puts e.get("href")
    assert(e.get("href")=~/shiyi.taobao.com/)
  end
end