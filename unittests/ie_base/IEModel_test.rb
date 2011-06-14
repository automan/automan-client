require File.dirname(__FILE__) + "/setup"

class ButtonTest < Test::Unit::TestCase
  def setup
		IEUtil.close_all_ies
	end
  def test_get_ies
    Watir::IE.start("s.taobao.com")
    assert_equal(IEModel.get_ies.length, 0)
    assert_equal(IEModel.get_all_ies.length, 1)
    assert_equal(IEModel.get_ies.length, 0)
    ie1 = IEModel.attach(/s/)
    assert_equal(IEModel.get_ies.length, 1)
    Watir::IE.start("qa.taobao.com")
    IEUtil.close_all_ies
    assert_equal(IEModel.get_all_ies.length, 0)
    assert_true(IEModel.last_ie.nil?)
  end

  def test_last_ie
    ie0 = IEModel.start("qa.taobao.com")
    Watir::IE.start("s.taobao.com")
    hwnd0 = ie0.current.hwnd
    ie01 = IEModel.attach(/qa/)
    assert_equal(IEModel.get_ies.length, 1)
    ie1 = IEModel.attach(/s/)
    assert_equal(IEModel.get_ies.length, 2)
    hwnd1 = ie1.current.hwnd

    ie2 = IEModel.start("www.taobao.com")

    assert_equal(IEModel.get_ies.length, 3)

    hwnd2 = ie2.current.hwnd
    ie_last = IEModel.last_ie
    assert_equal(ie_last.current.hwnd, hwnd2)
    ie_last.close

    ie_last2 = IEModel.last_ie
    assert_equal(ie_last2.current.hwnd, hwnd1)
    ie_last2.close

    assert_equal(IEModel.last_ie.current.hwnd, hwnd0)
    IEModel.last_ie.close
  end
end

