require File.dirname(__FILE__) + "/../setup"

include AWatir
class FindTests < Test::Unit::TestCase

  def setup
		goto_page("taobao.html")
  end

  def test_find_by_id
    ie = IEModel.attach(/taobao/)
    m = ie.cast(HtmlModel)
    m = m.convert(HtmlModel)
    e = m.find_element(AWatir::ATextField,"#not_exist_id")
    assert_equal(e.exist?, false)
    e.set "abc"
    e.click
    e = m.find_element(AWatir::ATextField,"#q")
    assert_equal(e.exist?, true)
    e.set "abc"
    e.click
  end

end
