require File.dirname(__FILE__) + "/setup"
  
class CaptureScreenTest < Test::Unit::TestCase

	def	test_capture_screen

    out = capture_stdout{
      captureDesktopJPG("capture_filename",capture_path=nil)
    }
    assert_match(/截屏成功：参见/,out)
    
	end
end
