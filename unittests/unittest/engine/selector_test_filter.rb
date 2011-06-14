require File.dirname(__FILE__) + "/../setup"

include AWatir
class LogTests < Test::Unit::TestCase

  def setup
		goto_page("selector.html")
  end

  def test_selector_filter_has
    ie = IEModel.attach(/selector.html/)
    m = ie.cast(HtmlModel)
    e = m.find_elements(AWatir::AElement, "td:has(a[id])")
    assert_equal(e.length, 2)
  end
end