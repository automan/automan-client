require File.dirname(__FILE__) + "/../../../lib/automan/support_tcommon"
require File.dirname(__FILE__) + "/../setup"

include AWatir
class FindTests < Test::Unit::TestCase

  def setup
		goto_page("taobao.html")
  end

  def test_find_by_id
    p = AutomanIE.start("www.baidu.com")
    p.model("body").text_field("#kw").set "123"
    p.button("#su").click
    p.models("body>table[id]")["ÊµÓÃ²éÑ¯"].link("td.f>a").click

    p2 = AutomanIE.attach(/baike/)
    p2.elements("a")["¼ò½é"].click
  end

end
