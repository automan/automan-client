require File.dirname(__FILE__) + "/setup"

class CheckTest < Test::Unit::TestCase
	def	test_verify_equal
    actual = "1"
    out = capture_stdout{
      CheckDb.verify_equal(actual, "3")
    }
    assert_match(/DB实际值：\|1\|/,out)
    assert_match(/预期值为：\|3\|/,out)
    assert_match( /verify_data_test.rb:7:in `test_verify_equal'/,out)

    out = capture_stdout{
      CheckText.verify_equal(actual, "2")
    }
    assert_match(/文本实际值：\|1\|/,out)

    out = capture_stdout{
      CheckDialog.verify_equal(actual, "1")
    }
    assert_match(/Dailog： 1-----校验正确/,out)

    out = capture_stdout{
      result = Check.statistic
      assert_equal(result,"TCFail")
    }
    assert_match(/本次运行累计的校验出错次数: 2次/,out)
    assert_match(/本次运行累计的操作失败次数: 0次/,out)
	end
end
8