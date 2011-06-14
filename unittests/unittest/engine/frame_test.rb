require File.dirname(__FILE__) + "/../setup"

include AWatir
class LogTests < Test::Unit::TestCase

  def setup
    #		goto_page("taobao.html")
  end

  def test_iframe
    #    ie = IEModel.attach(/taobao/)
    #    m = ie.cast(HtmlModel)
    #    eles = m.find_elements(AWatir::AElement,"body")
    #    puts eles
    ole = get_webbrowser2('0002120C')
    puts ole
  end

end